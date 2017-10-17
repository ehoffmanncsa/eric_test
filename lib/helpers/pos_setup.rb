# encoding: utf-8
require_relative '../../test/test_helper'

# Set up a new lead for POS base 2 conditions: grad year and package type
# choosing and returning 6 payments financing option as default 
# that way we can test for remaining balance and first payment made
class POSSetup
  def initialize
    @ui = LocalUI.new(true)
    @browser = @ui.driver
  end

  def set_username(email, username)
    @ui.user_login(email)
    @ui.wait.until { @browser.find_element(:name, 'commit').displayed? }

    @browser.find_element(:id, 'user_account_username').send_keys username
    @browser.find_element(:id, 'user_account_password').send_keys 'ncsa'
    @browser.find_element(:id, 'user_account_password_confirmation').send_keys 'ncsa'
    @browser.find_element(:name, 'commit').click
  end

  def make_commitment
    @ui.wait.until { @browser.find_element(:class, 'fa-angle-down').displayed? }

    # find the swoosh and go to commitment page
    swoosh = @browser.find_elements(:class, 'fa-swoosh')[4]
    raise '[ERROR] Cannot find swoosh' unless swoosh.enabled?

    @browser.find_element(:class, 'fa-angle-down').click; swoosh.click; 
    raise "[ERROR] Swoosh redir to #{@browser.title}" unless @browser.title.match(/Client Recruiting Management System/)

    # select all checkboxes
    ['profile', 'website', 'communication', 'supporting', 'process'].each do |commit|
      @browser.find_element(:id, commit).click; sleep 0.2
      @browser.find_element(:xpath, "//*[@id=\"#{commit}\"]/div[2]/div/div[2]/div/i").click; sleep 0.2
    end

    # then get activated
    get_activate = @browser.find_element(:class, 'button--next')
    raise '[ERROR] Cannot find activate button' unless get_activate.enabled?; get_activate.click
  end

  def get_cart_count
    count = @browser.find_element(:id, 'shopping-cart').find_element(:class, 'js-cart-count').text
    return count.gsub!(/[^0-9]/, '').to_i unless count.nil?
  end

  def choose_a_package(package)
    @browser.get 'https://qa.ncsasports.org/clientrms/membership/offerings'

    # get initial cart count
    cart_count = get_cart_count.nil? ? 0 : get_cart_count

    # scroll down and open up payment plan grid
    @browser.find_elements(:class, 'fa-swoosh')[0].location_once_scrolled_into_view
    @browser.find_elements(:class, 'financing')[0].find_element(:class, 'financing-js').click; sleep 0.5

    # get the cells from the last row for highest price options
    row = @browser.find_elements(:class, 'table-grid')[1].find_elements(:class, 'grid-row').last
    row.location_once_scrolled_into_view; sleep 0.2
    cells = row.find_elements(:class, 'cell')

    # select package as assigned, increment cart count by 1
    # return price of the selection
    case package
      when 'champion' then cells[2].click; cart_count += 1
      when  'elite' then cells[3].click; cart_count += 1
      when 'mvp' then cells[4].click; cart_count += 1
    end; sleep 3

    # compare cart count before and after selecting package
    new_cart_count = get_cart_count
    raise "[ERROR] Cart count #{new_cart_count} after selecting a package" unless cart_count.eql? new_cart_count

    # go to next step
    @browser.find_element(:class, 'button--next').location_once_scrolled_into_view
    @browser.find_element(:class, 'button--next').click; sleep 0.5
  end

  def choose_payment_plan(size = 'medium')
    check_discount_calculate

    # choose 6 months payment plan by default for testing purpose
    case size
      when 'small' then @browser.find_elements(:class, 'payment-block')[2].click
      else; @browser.find_elements(:class, 'payment-block')[1].click
    end
  end

  def pick_VIP_items(all = false)
    @browser.get 'https://qa.ncsasports.org/clientrms/membership/offerings'

    # get initial cart count
    cart_count = get_cart_count.nil? ? 0 : get_cart_count

    # activate alacarte table
    @browser.find_element(:class, 'alacarte-features').location_once_scrolled_into_view
    @browser.find_element(:class, 'alacarte-features').find_element(:class, 'vip-toggle-js').click; sleep 0.5

    # add one of each alacarte options into cart
    # and make sure cart count increments
    if all
      @browser.find_elements(:class, 'alacarte-block').each do |block|
        block.find_element(:class, 'button--medium').click; sleep 1
        cart_count += 1
        raise "[ERROR] Cart count #{cart_count} after selecting a package" unless cart_count.eql? get_cart_count
      end
    else
      block = @browser.find_elements(:class, 'alacarte-block').sample
      block.find_element(:class, 'button--medium').click; sleep 1
      cart_count += 1
      raise "[ERROR] Cart count #{cart_count} after selecting a package" unless cart_count.eql? get_cart_count
    end

    @browser.find_element(:class, 'button--next').click; sleep 0.5
  end

  def fill_out_credit
    config = YAML.load_file('config/config.yml')
    config['credit_billing'].each do |id, value|
      @browser.find_element(:id, id).send_keys value
    end
  end

  def fill_out_ACH
    @browser.find_element(:class, 'checking-js').click; sleep 0.5
    config = YAML.load_file('config/config.yml')
    config['checking_billing'].each do |id, value|
      @browser.find_element(:id, id).send_keys value
    end
  end

  # some selections will not need agreement and some does
  # so ignore this method when agreement not found
  def agreement_check
    begin
      @browser.find_element(:class, 'agreement-js').click
    rescue; end
  end

  def setup_billing(ach = false)
    # quickly pass through summary page, cannot check total here until cart bug is fixed,
    # items selected will be checked in membership/payment page
    @ui.wait(45) { @browser.find_element(:class, 'package-summary').displayed? }
    @browser.find_element(:class, 'summary-js').location_once_scrolled_into_view; sleep 0.5
    @browser.find_element(:class, 'summary-js').click

    @ui.wait(45) { @browser.find_elements(:class, 'custom-select')[2].displayed? }

    # fill out registration form
    specialists = @browser.find_elements(:class, 'custom-select')[1]
    options = specialists.find_elements(:tag_name, 'option')
    options.shift; options.sample.click

    coordinators = @browser.find_elements(:class, 'custom-select')[2]
    options = coordinators.find_elements(:tag_name, 'option')
    options.shift; options.sample.click

    @browser.find_element(:class, 'registration-js').click

    # billing agreement
    agreement_check

    # fill in payment info
    (ach.eql? true) ? fill_out_ACH : fill_out_credit

    # select state for billing address
    @browser.find_element(:id, 'order_billing_state_code').find_elements(:tag_name, 'option').sample.click
    @browser.find_element(:class, 'billing-js').click

    # sign and authorize
    @ui.wait(20).until { @browser.find_element(:id, 'order-submit').displayed? }
    @browser.find_element(:id, 'order_authorization_signature').click; sleep 0.2
    @browser.find_element(:id, 'order_authorization_signature').send_keys 'qa automation'
    @browser.find_element(:id, 'order-submit').click
  end

  def check_discount_calculate
    @ui.wait(20).until { @browser.find_element(:class, 'discount-js').displayed? }

    # activate discount feature
    @browser.find_element(:class, 'discount-js').location_once_scrolled_into_view
    @browser.find_element(:class, 'discount-js').click

    failure = []
    @ui.wait(20).until { @browser.find_elements(:class, 'payment-block')[0].displayed? }
    @full_price = @browser.find_elements(:class, 'payment-block')[0].attribute('data-total').gsub!(/[^0-9]/, '').to_i

    # Apply both discount code, one at a time
    # Collect all the prices and do calculation on the side
    # Compare the 2 numbers to make sure the displayed prices are calculated accurately
    ['NSLP', 'Military'].each do |code|
      @browser.find_element(:class, 'discount-code').click
      @browser.find_element(:class, 'discount-code').send_keys(code)
      @browser.find_element(:class, 'apply').click; sleep 0.5

      dsc_pmts = []
      @browser.find_elements(:class, 'payment-block').each do |block|
        dsc_pmts << block.attribute('data-total').gsub!(/[^0-9]/, '').to_i
      end

      cal_prices = []
      [1, 6, 12].each do |months|
        cal_prices << calculate(@full_price, months,  code)
      end

      cal_prices.zip(dsc_pmts).map { |c, d| failure << "Code #{code} - Actual: #{d} vs Expected: #{c}" unless c.eql? d }

      @browser.find_element(:id, 'registration').location_once_scrolled_into_view; sleep 0.5
      @browser.find_element(:class, 'remove-discount-js').click; sleep 0.7

      cal_prices.clear; dsc_pmts.clear
    end

    raise "[ERROR] Discount calculation is off #{failure}" unless failure.empty?
  end

  def calculate(full_price, months, discount_code = nil)
    interest_rate = 1
    pay_rate = 1

    case months
      when 6 then interest_rate = 1.11
      when 12 then interest_rate = 1.19
      when 18 then interest_rate = 1.194
    end

    case discount_code
      when 'NSLP' then pay_rate = 0.5
      when 'Military' then pay_rate = 0.9
    end

    (((full_price * interest_rate) / months) * pay_rate).round * months
  end

  def get_cart_total
    # open shopping cart
    @browser.find_element(:id, 'shopping-cart').click
    cart = @browser.find_element(:class, 'shopping-cart-open')
    
    total_price = cart.find_element(:class, 'total-pricing').text.gsub!(/[^0-9|\.]/, '').to_i
  end

  # to purchase only membership package
  def buy_package(email, username, package)
    set_username(email, username)
    make_commitment

    choose_a_package(package)
    choose_payment_plan
    setup_billing

    @browser.close

    membership = calculate(@full_price, 6)
    first_pymt = (membership / 6)
    
    [membership, first_pymt]
  end

  # to purchase only alacarte items
  def buy_alacarte(email, username, all = true)
    set_username(email, username)
    make_commitment

    pick_VIP_items(all)
    setup_billing

    @browser.close
  end

  # to purchase both a membership package and some alacarte items
  def buy_combo(email, username, package)
    set_username(email, username)
    make_commitment

    choose_a_package(package)
    choose_payment_plan('small')
    pick_VIP_items
    setup_billing

    @browser.close
  end

  # to make payment using ACH instead of credit card
  def buy_with_ACH_payment(email, username, package)
    set_username(email, username)
    make_commitment

    choose_a_package(package)
    choose_payment_plan
    setup_billing(true)

    @browser.close

    membership = calculate(@full_price, 6)
    first_pymt = (membership / 6)
    
    [membership, first_pymt]
  end
end
