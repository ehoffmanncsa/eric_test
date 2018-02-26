# encoding: utf-8
require_relative '../test_helper'

# TS-352: TED Regression
# UI Test: Allow Org Coach and NCSA Admin to Add Payment Method
class AddPaymentMethodTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection

    @coach_api = TEDApi.new('coach')
    @admin_api = TEDApi.new('admin')

    TEDContractApi.setup(@admin_api, @coach_api)
    @coach_token = @coach_api.header['Session-Token']
    @decoded_data = TEDContractApi.decode(@coach_token)
    @org_name = @decoded_data['organization_name']
    @org_id = @decoded_data['organization_id']

    creds = YAML.load_file('config/.creds.yml')
    @admin_username = creds['ted_admin']['username']
    @admin_password = creds['ted_admin']['password']
  end

  def teardown
    @browser.close
  end

  def imperson_coach
    org = find_org_in_ui
    org.click; sleep 1
    @browser.link(:text, 'Enter Org as Coach').click; sleep 3
  end

  def find_org_in_ui
    # find the Premium Signed section
    Watir::Wait.until(timeout: 45) { @browser.elements(:class, 'cards')[0].present? }
    board = @browser.elements(:class, 'cards')[0]
    premium_signed = board.elements(:class, 'col-sm-12')[0]
    header = premium_signed.element(:class, 'section-heading').text
    msg = 'This is not Premium Signed section'
    assert_equal header, 'Premium Signed', msg

    # find org and check count
    org_cards = premium_signed.elements(:class, 'org-card')
    org = org_cards.detect { |card| card.html.include? @org_name }
  end

  def modal
    @browser.div(:class, 'modal-content')
  end

  def add_payment
    # open add payment method modal
    @browser.button(:text, 'Add Payment Method').click

    fill_out_form
    select_dropdowns
    modal.button(:text, 'Submit').click; sleep 1
  end

  def fill_out_form
    first_name = MakeRandom.name
    last_name = MakeRandom.name

    inputs = modal.elements(:tag_name, 'input')
    inputs[0].send_keys first_name
    inputs[1].send_keys last_name
    inputs[2].send_keys '4242424242424242'
    inputs[3].send_keys MakeRandom.number(3)
    inputs[4].send_keys MakeRandom.number(5)
    inputs[5].send_keys MakeRandom.email

    # also return name for assertion
    @full_name = "#{first_name} #{last_name}"
  end

  def select_dropdowns
    lists = modal.select_lists(:class, 'form-control')
    lists.each do |list|
      options = list.options.to_a
      options.shift
      list.select options.sample.text
    end
  end

  def test_coach_add_payment_method
    UIActions.ted_coach_login
    TED.go_to_payment_method_tab

    add_payment
    TED.go_to_payment_method_tab
    assert_includes @browser.html, @full_name, 'New payment method not found'
  end

  def test_PA_add_payment_method
    UIActions.ted_coach_login(@admin_username, @admin_password)
    imperson_coach
    TED.go_to_payment_method_tab

    add_payment
    TED.go_to_payment_method_tab
    assert_includes @browser.html, @full_name, 'New payment method not found'
  end
end
