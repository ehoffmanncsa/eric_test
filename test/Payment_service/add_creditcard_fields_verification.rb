# frozen_string_literal: true

require_relative '../test_helper'
# C3PO Regression
# Add a creditcard info
# Test details: This test verfies that error message is displayed when imp fields are empty.
# This test also checks that save button is not enabled when all the fields are not populated.
class AddCreditCard < Common
  def setup
    super
    @email_addr = 'ncsa.automation+d5605418@gmail.com'
    @card_holder_first_name = MakeRandom.first_name
    @card_holder_last_name = MakeRandom.last_name
    @card_number = 4111111111111111
    @expiration_date = '05/2023'
    @security_code = 456
    @street_address = '1333 N kingsbury'
    @zipcode = '60642'
    @city = 'chicago'
  end

  def go_to_payment_page
    UIActions.user_login('ncsa.automation+d5605418@gmail.com', 'ncsa1333')
    sleep 2
    @browser.goto 'https://qa.ncsasports.org/clientrms/account/'
  end

  def add_credit_card_info
    @browser.element(class: 'fa-plus-circle').click
    add_name = @browser.element(name: 'credit_card_holder_name')
    add_name.send_keys %(#{@card_holder_first_name}  #{@card_holder_last_name} )
    add_name.to_subtype.clear
    failures = []
    add_name_empty_field_error = @browser.element(class: 'MuiFormHelperText-root', text: 'There was a problem. Please provide a valid name.')
    failures << 'Failed to display error' unless add_name_empty_field_error.present?
    assert_empty failures
    add_name.send_keys %(#{@card_holder_first_name}  #{@card_holder_last_name} )
  end

  def add_credit_card_number
    add_cc_number = @browser.element(name: 'credit_card_number')
    add_cc_number.send_keys @card_number
    add_cc_number.to_subtype.clear
    failures = []
    add_cc_number_field_error = @browser.element(class: 'MuiFormHelperText-root', text: 'There was a problem. Card number is not correct.')
    failures << 'Failed to display error' unless add_cc_number_field_error.present?
    assert_empty failures
    add_cc_number.send_keys @card_number
  end

  def add_expiration_date
    add_exp_date = @browser.element(name: 'expiration_date')
    add_exp_date.send_keys @expiration_date
    add_exp_date.to_subtype.clear
    failures = []
    add_exp_date_field_error = @browser.element(class: 'MuiFormHelperText-root', text: 'There was a problem. Expiration date is not correct.')
    failures << 'Failed to display error' unless add_exp_date_field_error.present?
    assert_empty failures
    add_exp_date.send_keys @expiration_date
  end

  def add_security_code
    add_v_code = @browser.element(name: 'credit_card_vcode')
    add_v_code.send_keys @security_code
    add_v_code.to_subtype.clear
    failures = []
    add_add_v_code_field_error = @browser.element(class: 'MuiFormHelperText-root', text: 'There was a problem. Security code is not correct.')
    failures << 'Failed to display error' unless add_add_v_code_field_error.present?
    assert_empty failures
    add_v_code.send_keys @security_code
  end

  def add_street_address
    @browser.element(name: 'billing_address').send_keys @street_address
  end

  def add_city
    @browser.element(name: 'billing_city').send_keys @city
  end

  def add_zip_code
    @browser.element(name: 'billing_zip').send_keys @zipcode
  end

  def choose_state
    select_button = @browser.element(id: 'mui-component-select-billing_state_id')
    select_button.click
    menu_popover = @browser.element(class: 'MuiList-root')
    options = menu_popover.element('role' => 'option', 'data-value' => '3')
    options.click
  end

  def verify_save_button_isdisabled?
    failures = []
    save_button = @browser.button(text: 'Save Card')
    failures << 'Failed to disable button' unless save_button.disabled?
    assert_empty failures
  end

  def save_card
    save_button = @browser.span(class: 'MuiButton-label', text: 'Save Card')
    sleep 2
    save_button.click
    end

  def test_Payment_service_add_credit_card
    go_to_payment_page
    add_credit_card_info
    add_credit_card_number
    add_expiration_date
    add_security_code
    verify_save_button_isdisabled?
    add_street_address
    add_city
    add_zip_code
    choose_state
    save_card
  end
end
