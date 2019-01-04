# encoding: utf-8

# Set up a new lead for POS base 2 conditions: grad year and package type
# choosing and returning 6 payments financing option as default
# that way we can test for remaining balance and first payment made
module POSSetup
  def self.setup(ui_object)
    @browser = ui_object
    UIActions.setup(@browser)
  end

  def self.set_password(email)
    UIActions.user_login(email); sleep 1

    @browser.refresh; sleep 1

    begin
      # in some cases there will be a popup modal for athlete to accept
      Watir::Wait.until { @browser.element(:class, 'mfp-content').visible? }
      popup = @browser.element(:class, 'mfp-content')
      popup.element(:class, 'button--secondary').click
    rescue; end

    Watir::Wait.until { @browser.text_field(:id, 'user_account_username').visible? }

    username = email.split('@')[0].delete('.').delete('+')
    @browser.text_field(:id, 'user_account_username').value = username
    @browser.text_field(:id, 'user_account_password').set 'ncsa'
    @browser.text_field(:id, 'user_account_password_confirmation').set 'ncsa'
    @browser.button(:name, 'commit').click
    sleep 1

    Watir::Wait.until(timeout: 90) { @browser.url.include? 'custom_drills/free_onboarding' }
    sleep 1
  end

  def self.make_commitment
    Watir::Wait.until { @browser.element(:class, 'fa-angle-down').visible? }
    @browser.element(:class, 'fa-angle-down').click

    # find the swoosh and go to commitment page
    dropdown = @browser.element(:class, 'jq-dropdown-panel')
    swoosh = dropdown.element(:class, 'fa-swoosh')
    raise '[ERROR] Cannot find swoosh' unless swoosh.enabled?

    swoosh.click;
    raise "[ERROR] Swoosh redir to #{@browser.title}" unless @browser.title.match(/Client Recruiting Management System/)

    # select all checkboxes
    # I can't seem to find any better option then xpath for the checkbox yet
    ['profile', 'website', 'communication', 'supporting', 'process'].each do |commit|
      div = @browser.div(:id, commit)
      div.click
      div.element(:xpath, "//*[@id=\"#{commit}\"]/div[2]/div/div[2]/div/i").click
    end

    # then get activated
    get_activate = @browser.div(:class, 'button--next')
    raise '[ERROR] Cannot find activate button' unless get_activate.enabled?

    get_activate.click
    sleep 1
  end

  def self.goto_offerings
    clientrms = Default.env_config['clientrms']
    @browser.goto(clientrms['base_url'] + clientrms['offerings_page'])
  end

  def self.get_cart_count
    cart = @browser.element(:id, 'shopping-cart')
    count = cart.element(:class, 'js-cart-count').text
    return count.gsub!(/[^0-9]/, '').to_i unless count.nil?
  end

  def self.open_payment_plan
    payment_plan = @browser.link(:text, 'Choose Payment Plan')
    payment_plan.click; sleep 0.5
    payment_plan.scroll.to :center
  end

  def self.choose_a_package(package)
    goto_offerings

    # get initial cart count
    cart_count = get_cart_count.nil? ? 0 : get_cart_count

    # open up payment plan grid
    open_payment_plan

    # get the cells from the last row for highest price options
    block = @browser.div(:class, 'payment-plans-js')
    table = block.div(:class, 'table-grid')
    rows = table.divs(:class, 'grid-row')
    cells = rows.last.divs(:class, 'cell').to_a

    # select package as assigned, increment cart count by 1
    # return price of the selection
    case package
    when 'champion' then cells[2].click; cart_count += 1
      when  'elite' then cells[3].click; cart_count += 1
      when 'mvp' then cells[4].click; cart_count += 1
    end; sleep 2

    # compare cart count before and after selecting package
    new_cart_count = get_cart_count
    msg = "[ERROR] Cart count #{new_cart_count} after selecting a package"
    raise msg unless cart_count.eql? new_cart_count

    # go to next step
    @browser.element(:class, 'button--next').click; sleep 1
    Watir::Wait.until(timeout: 90) { @browser.url.include? 'clientrms/membership/enrollment' }
  end

  def self.choose_payment_plan(size = nil)
    # choose 6 months payment plan by default for testing purpose
    Watir::Wait.until(timeout: 45) { @browser.element(:class, 'payment-block').present? }
    blocks = @browser.elements(:class, 'payment-block').to_a
    full_price = blocks[0].attribute_value('data-total').gsub!(/[^0-9]/, '').to_i

    size ||= 'medium'
    case size
      when 'small' then blocks[2].click
      else; blocks[1].click
    end

    @browser.element(:class, 'summary-js').click

    full_price
  end

  def self.apply_discount_enrollment(code)
    @browser.text_field(:placeholder, 'Discount Code').value = code
    @browser.element(:class, 'apply').click; sleep 2
    Watir::Wait.until { discount_message.present? }

    check_discount_message(code)
  end

  def self.apply_discount_offerings(code)
    @browser.element(:placeholder, 'Enter Discount Code').send_keys code
    @browser.element(:class, 'apply').click; sleep 2
    Watir::Wait.until { discount_message.present? }

    check_discount_message(code)
  end

  def self.discount_message
    @browser.element(:class, 'discount-message')
  end

  def self.check_discount_message(code)
    expect_msg = "Discount code #{code.upcase} successfully applied"
    actual_msg = discount_message.text.split('!').first
    raise "[Incorrect Message] Expect: #{expect_msg} - Actual: #{actual_msg}" unless actual_msg.eql? expect_msg
  end

  def self.remove_discount
    @browser.link(:text, 'Remove').click
    Watir::Wait.while { discount_message.present? }
  end

  def self.calculate(full_price, months, discount_code = nil)
    interest_rate = 1
    case months
      when 6 then interest_rate = 1.11
      when 12 then interest_rate = 1.19
      when 18 then interest_rate = 1.194
    end

    pay_rate = (discount_code.nil?) ? 1 : (1 - Default.static_info['ncsa_discount_code'][discount_code].to_f)

    # Adarsh's recipe
    # ((((original_amount * (1 - percent_amount)).round) * interest_rate) / months).round
    ((((full_price * pay_rate).round) * interest_rate) / months).round * months
  end

  def self.check_enrollment_discount_calculate(enroll_yr = nil)
    # if nothing is passed in, assume freshman
    enroll_yr ||= 'freshman'

    failure = []
    full_price = @browser.elements(:class, 'payment-block')[0].attribute_value('data-total').gsub!(/[^0-9]/, '').to_i

    # activate discount feature
    @browser.span(:class, 'discount-js').click

    ['nslp', 'military'].each do |code|
      apply_discount_enrollment(code)

      dsc_pmts = []
      @browser.elements(:class, 'payment-block').each do |block|
        dsc_pmts << block.attribute_value('data-total').gsub!(/[^0-9]/, '').to_i
      end

      cal_prices = []
      months = [1, 6, 12] # add 18 here when that feature available and pop last 2 if senior
      months.pop if enroll_yr == 'senior'
      months.each do |months|
        cal_prices << calculate(full_price, months, code)
      end

      cal_prices.zip(dsc_pmts).map do |c, d|
        msg = "Code #{code} - Actual: #{d} vs Expected: #{c}"
        failure << msg unless c.eql? d
      end

      remove_discount
      cal_prices.clear; dsc_pmts.clear
    end

    raise "[ERROR] Discount calculation is off #{failure}" unless failure.empty?
  end

  def self.pick_VIP_items(all = false)
    goto_offerings

    # get initial cart count
    cart_count = get_cart_count.nil? ? 0 : get_cart_count

    # activate alacarte table
    @browser.element(:class, 'alacarte-features').element(:class, 'vip-toggle-js').click

    # add one of each alacarte options into cart
    # and make sure cart count increments
    msg = "[ERROR] Cart count #{get_cart_count} after selecting #{cart_count} VIP items"
    if all
      @browser.elements(:class, 'alacarte-block').each do |block|
        block.element(:class, 'button--medium').click; sleep 2
        cart_count += 1
        raise msg unless cart_count.eql? get_cart_count
      end
    else
      block = @browser.elements(:class, 'alacarte-block').to_a.sample
      block.element(:class, 'button--medium').click; sleep 2
      cart_count += 1
      raise msg unless cart_count.eql? get_cart_count
    end

    2.times { @browser.element(:class, 'button--next').click }
  end

  def self.fill_out_credit
    Default.static_info['credit_billing'].each do |id, value|
      @browser.text_field(:id, id).set value
    end
  end

  def self.fill_out_ACH
    @browser.element(:class, 'checking-js').click
    Default.static_info['checking_billing'].each do |id, value|
      @browser.text_field(:id, id).set value
    end
  end

  def self.agreement_check
    # some selections will not need agreement and some does
    # so ignore this method when agreement not found
    begin
      Watir::Wait.until { @browser.element(:class, 'agreement-js').visible? }
      @browser.element(:class, 'agreement-js').click
      sleep 1
    rescue; end
  end

  def self.fill_out_registration_form
    # guardian email
    @browser.text_field(:id, 'order_guardian_email').set 'fake@fake.com'

    # select specialist
    specialists = @browser.select_list(:id, 'order_head_scout_id')
    names = specialists.options.to_a; names.shift
    specialists.select(names.sample.text)

    # select coordinator
    coordinators = @browser.select_list(:id, 'order_rc_user_id')
    names = coordinators.options.to_a; names.shift
    coordinators.select(names.sample.text)

    # click next button
    @browser.element(:class, 'registration-js').click
  end

  def self.select_billing_state
    # select state for billing address
    state = @browser.select_list(:id, 'order_billing_state_code')
    names = state.options.to_a; names.shift
    state.select(names.sample.text)

    # click next button
    @browser.element(:class, 'billing-js').click
  end

  def self.sign_and_auth
    # sign and authorize
    Watir::Wait.until { @browser.element(:id, 'order-submit').visible? }
    @browser.text_field(:id, 'order_authorization_signature').set 'qa automation'
    sleep 1
    @browser.element(:id, 'order-submit').click; sleep 1
  end

  def self.setup_billing(ach = false)
    fill_out_registration_form
    agreement_check
    sleep 1

    # fill in payment info depends on which way was chosen
    (ach.eql? true) ? fill_out_ACH : fill_out_credit
    select_billing_state

    sign_and_auth

    # probably need to chill a bit here or else lightning bolt if viewing Payments right after
    sleep 10
  end

  def self.get_cart_total
    # open shopping cart
    @browser.element(:id, 'shopping-cart').click
    cart = @browser.element(:class, 'shopping-cart-open')

    total_price = cart.element(:class, 'total-pricing').text.gsub!(/[^0-9|\.]/, '').to_i
  end

  # to purchase only membership package
  def self.buy_package(email, package)
    set_password(email)
    make_commitment
    choose_a_package(package)
    choose_payment_plan
    setup_billing

    UIActions.clear_cookies
  end

  # to purchase only alacarte items
  def self.buy_alacarte(email, all = true)
    set_password(email)
    make_commitment
    pick_VIP_items(all)
    setup_billing

    UIActions.clear_cookies
  end

  # to purchase both a membership package and some alacarte items
  def self.buy_combo(email, package)
    set_password(email)
    make_commitment
    choose_a_package(package)
    choose_payment_plan('small')
    pick_VIP_items
    setup_billing

    UIActions.clear_cookies
  end

  # to make payment using ACH instead of credit card
  def self.buy_with_ACH_payment(email, package)
    set_password(email)
    make_commitment
    choose_a_package(package)
    choose_payment_plan
    setup_billing(true)

    UIActions.clear_cookies
  end
end
