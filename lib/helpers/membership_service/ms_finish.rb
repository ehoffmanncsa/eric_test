# encoding: utf-8

# Set up a new lead for POS base 2 conditions: grad year and package type
# choosing and returning 6 payments financing option as default
# that way we can test for remaining balance and first payment made
module MSFinish
  def self.setup(ui_object)
    @browser = ui_object
  end

  def self.accept_summary
    button = @browser.element(id: 'summary').element(class: 'button--next')
    button.scroll.to :center; sleep 1
    @browser.element(id: 'summary').element(class: 'button--next').click
    sleep 2
  end

  def self.fill_out_registration_form
    # guardian email
    @browser.text_field(id: 'order_guardian_email').set 'fake@fake.com'

    # select specialist
    specialists = @browser.select_list(id: 'order_head_scout_id')
    names = specialists.options.to_a; names.shift
    specialists.select(names.sample.text)

    # select coordinator
    coordinators = @browser.select_list(id: 'order_rc_user_id')
    names = coordinators.options.to_a; names.shift
    coordinators.select(names.sample.text)

    # click next button
    @browser.element(class: 'registration-js').click
  end

  def self.fill_out_credit
    Default.static_info['credit_billing'].each do |id, value|
      @browser.text_field(id: id).set value
    end
  end

  def self.fill_out_ACH
    @browser.element(class: 'checking-js').click
    Default.static_info['checking_billing'].each do |id, value|
      @browser.text_field(id: id).set value
    end
  end

  def self.select_billing_state
    # select state for billing address
    state = @browser.select_list(id: 'order_billing_state_code')
    names = state.options.to_a; names.shift
    state.select(names.sample.text)

    # click next button
    @browser.element(class: 'billing-js').click
  end

  def self.sign_and_auth
    # sign and authorize
    Watir::Wait.until { @browser.element(id: 'order-submit').present? }
    @browser.text_field(id: 'order_authorization_signature').set 'qa automation'
    sleep 1
    @browser.element(id: 'order-submit').click; sleep 5
  end

  def self.setup_billing(ach = false)
    accept_summary
    fill_out_registration_form
    sleep 1

    # fill in payment info depends on which way was chosen
    (ach.eql? true) ? fill_out_ACH : fill_out_credit
    select_billing_state

    sign_and_auth

    # need to chill a bit here or else lightning bolt when view Payments immediately after
    sleep 10
  end
end
