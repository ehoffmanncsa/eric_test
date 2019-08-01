# encoding: utf-8
require_relative '../test_helper'

# MS Regression
# TS-438
# UI Test: Upgrade client membership from Champion to Elite

class UpgradeChampionToEliteTest < Common
 def setup
   super
   UIActions.fasttrack_login
   MSAdmin.setup(@browser)
   C3PO.setup(@browser)

   @client_id = MSAdmin.retrieve_client_id_by_program('Champion')
 end

 def teardown
   super
 end

 def upgrade_to_elite
   @browser.i(class: 'fa-pencil').click
   modal.select_list(name: 'packageName').select 'Elite'
   modal.select_list(name: 'numPayments').select rand(1 .. 18).to_s
   modal.button(value: 'Preview Membership Change').click
   sleep 2
   Watir::Wait.until(timeout: 30) { modal.div(class: %w[js_change_payment change_form]).present? }
   modal.button(value: 'Change Membership').click
   sleep 5
   @browser.refresh
 end

 def modal
   @browser.div(class: 'modal')
 end

 def check_package_upgraded
   account_summary = @browser.div(class: 'account-summary')
   list = account_summary.element(tag_name: 'ul')
   assert (list.lis[0].text.include? 'Elite'), 'Package is not upgraded to Elite.'
 end

 def check_client_video_count
   C3PO.impersonate(@client_id)
   C3PO.goto_video

   # Champion originally has 1 NCSA video, upgrading to Elite should have 2
   # But in case 1 was redeemed, 1 remaining is acceptable
   assert ncsa_video_count >= 1, 'Incorrect video count after upgrading.'
 end

 def ncsa_video_count
   counter_section = @browser.div(class: %w[clr mg-btm-1])
   counter_section.divs(class: 'remaining')[0].div(class: 'number').text.to_i
 end

 def test_upgrade_champion_to_elite
   MSAdmin.goto_payments_page(@client_id)

   upgrade_to_elite
   check_package_upgraded
   check_client_video_count
 end
end
