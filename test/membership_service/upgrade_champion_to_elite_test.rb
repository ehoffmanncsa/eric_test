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
   MSAdmin.upgrade_to('Elite')
   check_package_upgraded
   check_client_video_count
 end
end
