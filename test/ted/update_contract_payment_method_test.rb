# encoding: utf-8
require_relative '../test_helper'

# TS-369: TED Regression
# UI Test: Allow Org Coach and NCSA Admin to Assign Payment Method to Contract

=begin
  Require organization to have more than 1 payment account
  Org Awesome Volleyball, Coach Joshua
  Create a new contract, sign and authorize via API
  Collect all the existing payment account ids of the org
  Exclude the id that the contract is currently using
  In the UI, as a coach go to Administration/Payment method
  Find the contract, view Details and change payment method
  Make sure there is success message
  Check API endpoint contract to make sure account id is updated
  Delete contract
  Create a new contract, sign and authorize via API
  Collect all the existing payment account ids of the org
  Exclude the id that the contract is currently using
  In the UI, as a PA, impersonate org, go to Administration/Payment method
  Find the contract, view Details and change payment method
  Make sure there is success message
  Check API endpoint contract to make sure account id is updated
  Delete contract
=end

class UpdateContractPaymentMethodTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    TED.setup(@browser)
    TEDContractApi.setup

    @gmail = GmailCalls.new
    @gmail.get_connection

    @coach_api = TEDContractApi.coach_api
    @admin_api = TEDContractApi.admin_api

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

  def setup_contract
    # add new contract, accept TOS and submit CC
    new_contract = TEDContractApi.add_contract
    @contract_id = new_contract['id']
    TEDContractApi.accept_terms_of_service(@contract_id, @decoded_data)
    TEDContractApi.submit_credit_card_info(@contract_id, @decoded_data)

    # there will be emails so clean them up
    subject = "#{@org_name} has signed Terms of Service and authorized credit card"
    cleanup_emails(subject)
  end

  def cancel_contract
    TEDContractApi.cancel_signed_contract(@contract_id)

    # there will be emails so clean them up
    subject = "CANCEL NOTICE: #{@org_name}"
    cleanup_emails(subject)
  end

  def cleanup_emails(subject)
    @gmail.mail_box = 'Inbox'
    @gmail.subject = subject
    emails = @gmail.get_unread_emails
    refute_empty emails, "#{subject} emails not found"

    @gmail.delete(emails)
  end

  def get_org_account_ids
    endpoint = "organizations/#{@org_id}/organization_accounts"
    data = @admin_api.read(endpoint)['data']
    ids = []
    data.each { |d| ids << d['id'] }

    ids
  end

  def get_contract_account_id
    endpoint = "organization_contracts/#{@contract_id}"
    data = @admin_api.read(endpoint)['data']

    data['attributes']['payment-account-id']
  end

  def get_another_acc_id
    current_acc_id = get_contract_account_id.to_s
    org_acc_ids = get_org_account_ids
    org_acc_ids.delete(current_acc_id)

    org_acc_ids.sample
  end

  def update_payment_method(new_id)
    TED.go_to_details_tab

    # open contract details
    contract = find_contract_in_ui
    contract.button(:text, 'Details').click

    # in contract details change payment method
    modal.link(:text, 'Change payment method').click
    list = modal.select_list(:class, 'form-control')
    list.select_value(new_id); sleep 1
  end

  def modal
    @browser.div(:class, 'modal-content')
  end

  def check_success_message
    Watir::Wait.until { modal.div(:class, 'alert').present? }
    expected = 'Payment change was successful.'
    actual = modal.div(:class, 'alert').text
    assert_equal expected, actual, 'Unexpected message'
  end

  def check_update_successful(new_acc_id)
    updated_acc_id = get_contract_account_id.to_s
    assert_equal new_acc_id, updated_acc_id, 'Account ID not updated'
  end

  def find_contract_in_ui
    column = @browser.divs(:class, 'col-lg-6').last
    Watir::Wait.until { column.element(:class, 'table').present? }
    table = column.element(:class, 'table')

    table.element(:text, @org_name).parent
  end

  def test_coach_update_contract_payment_method
    setup_contract

    new_acc_id = get_another_acc_id
    UIActions.ted_login

    update_payment_method(new_acc_id)
    check_success_message
    check_update_successful(new_acc_id)
    cancel_contract
  end

  def test_PA_update_contract_payment_method
    setup_contract

    new_acc_id = get_another_acc_id
    TED.impersonate_org(@org_id)

    update_payment_method(new_acc_id)
    check_success_message
    check_update_successful(new_acc_id)
    cancel_contract
  end
end
