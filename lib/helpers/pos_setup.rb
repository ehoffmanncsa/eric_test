# encoding: utf-8
require_relative '../../test/test_helper'

# Set up a new lead for POS base 2 conditions: grad year and package type
# choosing and returning 6 payments financing option as default 
# that way we can test for remaining balance and first payment made
class POSSetup
  def initialize; end

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

    # verify the swoosh is enabled
    swoosh = @browser.find_elements(:class, 'fa-swoosh')[4]
    raise '[ERROR] Cannot find swoosh' unless swoosh.enabled?

    # go to commitment page, make sure the right page loads
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

  def choose_a_package(package)
    @browser.get 'https://qa.ncsasports.org/clientrms/membership/offerings'

    # scroll down and open up choose payment plan grid
    @browser.find_elements(:class, 'fa-swoosh')[0].location_once_scrolled_into_view
    @browser.find_elements(:class, 'financing')[0].find_element(:class, 'financing-js').click; sleep 0.5

    row = @browser.find_elements(:class, 'table-grid')[1].find_elements(:class, 'grid-row').last
    row.location_once_scrolled_into_view; sleep 0.2
    cells = row.find_elements(:class, 'cell')

    case package
      when 'champion' then cells[2].click
      when  'elite' then cells[3].click
      when 'mvp' then cells[4].click
    end; sleep 1

    cart_count = @browser.find_element(:id, 'shopping-cart').find_element(:class, 'js-cart-count').text.gsub!(/[^0-9]/, '').to_i
    raise "[ERROR] Cart count #{cart_count} after selecting a package" unless cart_count.eql? 1

    @browser.find_element(:class, 'button--next').click; sleep 1
  end

  def choose_payment_plan
    check_discount_calculate

    @browser.find_elements(:class, 'payment-block')[1].click
    @browser.find_element(:class, 'summary-js').click; sleep 1
  end

  def setup_billing
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
    @browser.find_element(:class, 'agreement-js').click

    # fill out billing info
    config = YAML.load_file('config/config.yml')
    billing_info = config['billing']
    billing_info.each do |id, value|
      @browser.find_element(:id, id).send_keys value
    end

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
    @browser.find_element(:class, 'discount-js').location_once_scrolled_into_view
    @browser.find_element(:class, 'discount-js').click

    failure = []
    @full_price = @browser.find_elements(:class, 'payment-block')[0].attribute('data-total').gsub!(/[^0-9]/, '').to_i
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

  def setup(email, username, package)
    @ui = LocalUI.new(true)
    @browser = @ui.driver

    set_username(email, username)
    make_commitment
    choose_a_package(package)
    choose_payment_plan
    setup_billing

    @browser.close

    membership = calculate(@full_price, 6)
    firt_pymt = (membership / 6)
    
    [membership, firt_pymt]
  end
end
