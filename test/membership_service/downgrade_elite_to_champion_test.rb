# encoding: utf-8
require_relative '../test_helper'

# MS Regression
# TS-442
# UI Test: Downgrade client membership from Elite to Champion

class DowngradeEliteToChampionTest < Common
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

 def check_package_downgraded
   account_summary = @browser.div(class: 'account-summary')
   list = account_summary.element(tag_name: 'ul')
   assert (list.lis[0].text.include? 'Champion'), 'Package is not downgraded to Champion.'
 end

 def check_client_video_count
   C3PO.impersonate(@client_id)
   C3PO.goto_video

   # Elite originally has 2 NCSA videos + 1 Covid, downgrading to Champion should have 1 or 2
   # But in case 1 or 2 video was redeemed, 1 or 2 remaining is acceptable
   assert ncsa_video_count <= 2, 'Incorrect video count after upgrading.'
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

   coaching_session_count = coaching_session.text.split('(')[1].gsub(/\D/, '').to_i
   evaluation_session_count = evaluation_session.text.split('(')[1].gsub(/\D/, '').to_i

   failure = []
   failure << "Has coaching session while not supposed to." unless coaching_session_count == 0
   failure << "Has evaluation session while not supposed to." unless evaluation_session_count == 0
   assert_empty failure
 end

 def open_sessions_dropdown
   @browser.div(id: 'session_type_dropdown_chosen').click
 end

 def dropdown
   @browser.ul(class: 'chosen-results')
 end

 def test_downgrade_elite_to_champion
   MSAdmin.goto_payments_page(@client_id)
   MSAdmin.upgrade_or_down_grade_to('Champion')
   check_package_downgraded
   check_client_video_count
   check_coaching_and_evaluation_sessions
 end
end
