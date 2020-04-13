# encoding: utf-8
require_relative '../test_helper'

# TS-356: TED Regression
# UI Test: Do not include Contracts that are canceled on Dashboard

=begin
  PA Otto Mation, Org Awesome Sauce, Coach Tiffany
  You won't see much activities in the UI because
  the majority are done via API requests
  Login to TED as PA, get org AV's contract count on dashboard
  Create contract, sign and authorize it
  Refresh the UI make sure contract count has increased
  Cancel the contract via API
  Refresh the UI and make sure contract count back to original
  All emails related to this process are checked and deleted afterward
=end

class DashboardNotShowCanceledContractTest < Common
  def setup
    super

    TEDContractApi.setup
    TED.setup(@browser)

    @partner_username = Default.env_config['ted']['partner_username']
    @partner_password = Default.env_config['ted']['partner_password']

    @org_name = TEDContractApi.org_name
  end

  def teardown
    super
  end

  def search_for_org
    @browser.input(type: 'search').send_keys @org_name
    @browser.button(text: 'Search').click
    UIActions.wait_for_spinner
  end

  def get_contract_count
    search_for_org

    org = @browser.element(text: @org_name).parent
    text = org.element(class: 'subtitle').text
    arr = text.split(' ')
    arr.pop

    arr.last.to_i
  end

  def test_canceled_contract_not_show_on_dashboard
    UIActions.ted_login(@partner_username, @partner_password)
    original_contract_count = get_contract_count

    # silently add contracts via api
    new_contract_id = TEDContractApi.create_contract_complete_process
    @browser.refresh

    # check count increase after added contract
    new_count = get_contract_count
    assert (original_contract_count < new_count), 'Number of contracts did not increase'

    # now cancel it
    TEDContractApi.cancel_signed_contract(new_contract_id)
    @browser.refresh

    # check dashboard make sure contract count is correct
    new_count = get_contract_count
    assert_equal original_contract_count, new_count, 'Number of contracts did not decrease'

    TEDContractApi.cleanup_email('Inbox')
  end
end
