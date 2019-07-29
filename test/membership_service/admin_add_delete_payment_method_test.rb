# encoding: utf-8
require_relative '../test_helper'

# MS Regression
# TS-488, TS-489
# UI Test: Create/Delete A Payment Method Test (Admin Payments Page)

class AdminAddDeletePaymentMethodTest < Common
  def setup
    super
    UIActions.fasttrack_login
    MSAdmin.setup(@browser)

    @card_nickname = MakeRandom.company_name
    puts "card nickname: #{@card_nickname}"
  end

  def teardown
    super
  end

  def add_form_locator
    @browser.form(class: %w[simple_form payment_method payment-method-js])
  end

  def fill_out_textfields
    add_form_locator.text_field(name: 'firstName').set MakeRandom.first_name
    add_form_locator.text_field(name: 'middleInitial').set MakeRandom.name(1)
    add_form_locator.text_field(name: 'lastName').set MakeRandom.last_name
    add_form_locator.text_field(name: 'accountNickname').set @card_nickname
    add_form_locator.text_field(name: 'cardNumber').set '4111111111111111'
    add_form_locator.text_field(name: 'cvv').set '111'
    add_form_locator.text_field(name: 'phone').set MakeRandom.phone_number
    add_form_locator.text_field(name: 'email').set MakeRandom.fake_email
    add_form_locator.text_field(name: 'billingAddress').set MakeRandom.address
    add_form_locator.text_field(name: 'billingCity').set MakeRandom.city
    add_form_locator.text_field(name: 'billingZip').set MakeRandom.number(5)
  end

  def select_month_and_state
    %w(expirationMonth billingState).each do |name|
      list = add_form_locator.select_list(name: name)
      options = list.options.to_a
      list.select options.sample.text
    end
  end

  def select_year
    year = Time.now.year + rand(1 .. 5)
    add_form_locator.select_list(name: 'expirationYear').select year.to_s
  end

  def create_payment_method
    fill_out_textfields
    select_month_and_state
    select_year

    @browser.div(text: 'Save Payment Method').click
    sleep 5
  end

  def methods_file
    @browser.div(id: 'methods-file')
  end

  def new_added_method
    methods_file.divs(class: 'method-js ').each do |method|
      return method if method.div(class: 'method-head').div(class: %w[column two-thirds]).text == @card_nickname
    end

    return nil
  end

  def new_method_found
    return true unless new_added_method.nil?
    false
  end

  def check_method_created
    assert new_method_found, 'Cannot locate new added method.'
  end

  def delete_payment_method
    button_group = new_added_method.div(class: %w[column third editing-buttons])
    button_group.a(class: 'delete-method-js').click
    button_group.a(class: 'button--red').click
  end

  def delete_method_section
    @browser.div(class: 'deleted-methods')
  end

  def find_deleted_payment_method
    delete_method_section.element(class: 'deleted-payments-js').click
    return true if delete_method_section.element(text: @card_nickname).present?
    false
  end

  def check_method_deleted
    assert find_deleted_payment_method, 'Deleted payment method not found'
  end

  def test_create_delete_payment_method
    MSAdmin.goto_payments_page

    create_payment_method
    check_method_created

    if new_method_found
      delete_payment_method
      check_method_deleted
    end
  end
end
