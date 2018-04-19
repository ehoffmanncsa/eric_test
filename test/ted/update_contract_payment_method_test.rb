# encoding: utf-8
require_relative '../test_helper'

# TS-369: TED Regression
# UI Test: Allow Org Coach and NCSA Admin to Assign Payment Method to Contract

=begin
  Require organization to have more than 1 payment account
  Use Org Awesome Sauce, Coach Tiffany, PA Otto, contract id 409
  Collect all the existing payment account ids of the org
  Exclude the id that the contract is currently using

  For Coach:
  In the UI, as a coach go to Administration/Payment method
  Find the contract, view Details and change payment method
  Make sure there is success message
  Check API endpoint contract to make sure account id is updated

  For PA:
  In the UI, as a PA, impersonate org, go to Administration/Payment method
  Find the contract, view Details and change payment method
  Make sure there is success message
  Check API endpoint contract to make sure account id is updated
=end

class UpdateContractPaymentMethodTest < Common
  def setup
    super
    TED.setup(@browser)

    TEDContractApi.setup
    @admin_api = TEDContractApi.admin_api
    @org_name = TEDContractApi.org_name
    @org_id = TEDContractApi.org_id
    @contract_id = '422' # Use this contract for this scenario
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
    TED.go_to_organization_tab

    # open contract details
    contract = find_contract_in_ui
    contract.button(:text, 'Details').click

    # in contract details change payment method
    modal.link(:text, 'Change payment method').click
    list = modal.select_list(:class, 'form-control')
    list.select new_id
  end

  def find_contract_in_ui
    column = @browser.element(:text, 'Signed Contracts').parent.parent
    table = column.element(:class, 'table')

    table.element(:text, @org_name).parent # find contract Accepted By 'Awesome Sauce'
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

  def test_coach_update_contract_payment_method
    UIActions.ted_login
    new_acc_id = get_another_acc_id
    update_payment_method(new_acc_id)
    check_success_message
    check_update_successful(new_acc_id)
  end

  def test_PA_update_contract_payment_method
    TED.impersonate_org(@org_id)
    new_acc_id = get_another_acc_id
    update_payment_method(new_acc_id)
    check_success_message
    check_update_successful(new_acc_id)
  end
end
