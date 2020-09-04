# encoding: utf-8
require_relative '../test_helper'

# MS Regression
# TS-443
# UI Test: Upgrade client membership from Elite to MVP

class UpgradeEliteToMVPTest < Common
 def setup
   super
   UIActions.fasttrack_login
   MSAdmin.setup(@browser)
   C3PO.setup(@browser)

   @client_id = MSAdmin.retrieve_client_id_by_program('Elite')
 end

 def teardown
   super
 end

 def check_package_upgraded
   account_summary = @browser.div(class: 'account-summary')
   list = account_summary.element(tag_name: 'ul')
   assert (list.lis[0].text.include? 'MVP'), 'Package is not upgraded to MVP.'
 end

 def check_client_video_count
   C3PO.impersonate(@client_id)
   C3PO.goto_video

   # Elite originally has 2 NCSA video, upgrading to MVP should have 4
   # But in case 2 was redeemed, 2 remaining is acceptable
   assert ncsa_video_count >= 2, 'Incorrect video count after upgrading.'
 end

 def ncsa_video_count
   counter_section = @browser.div(class: %w[clr mg-btm-1])
   counter_section.divs(class: 'remaining')[0].div(class: 'number').text.to_i
 end

 def check_coaching_and_evaluation_sessions
   C3PO.goto_coaching_session
   open_sessions_dropdown

   coaching_session = dropdown.li('data-option-array-index': '2')
   evaluation_session = dropdown.li('data-option-array-index': '3')

   coaching_session_count = coaching_session.text.split('(')[1].gsub(/[^A-Za-z]/, '')
   evaluation_session_count = evaluation_session.text.split('(')[1].gsub(/[^A-Za-z]/, '')

   failure = []
   failure << "Does not have any coaching session." unless coaching_session_count == 'AsNeeded'
   failure << "Does not have any evaluation session." unless evaluation_session_count == 'AsNeeded'
   assert_empty failure
 end

 def open_sessions_dropdown
   @browser.div(id: 'session_type_dropdown_chosen').click
 end

 def dropdown
   @browser.ul(class: 'chosen-results')
 end

 def test_upgrade_elite_to_mvp
   MSAdmin.goto_payments_page(@client_id)
   MSAdmin.upgrade_or_down_grade_to('MVP')
   check_package_upgraded
   check_client_video_count
   check_coaching_and_evaluation_sessions
 end
end
