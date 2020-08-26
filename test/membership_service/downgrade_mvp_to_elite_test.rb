# encoding: utf-8
require_relative '../test_helper'

# MS Regression
# TS-440
# UI Test: Downgrade client membership from MVP to Elite

class DowngradeMVPToEliteTest < Common
 def setup
   super
   UIActions.fasttrack_login
   MSAdmin.setup(@browser)
   C3PO.setup(@browser)

   @client_id = MSAdmin.retrieve_client_id_by_program('MVP')
 end

 def teardown
   super
 end

 def check_package_downgraded
   account_summary = @browser.div(class: 'account-summary')
   list = account_summary.element(tag_name: 'ul')
   assert (list.lis[0].text.include? 'Elite'), 'Package is not downgraded to Elite.'
 end

 def check_client_video_count
   C3PO.impersonate(@client_id)
   C3PO.goto_video

   # MVP originally has 4 NCSA videos + 1 Covid,, downgrading to Elite should have at most 3
   assert ncsa_video_count <= 3, 'Incorrect video count after upgrading.'
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
   failure << "Has more than 1 coaching session." unless coaching_session_count == 1
   failure << "Has more than 1 evaluation session." unless evaluation_session_count == 1
   assert_empty failure
 end

 def open_sessions_dropdown
   @browser.div(id: 'session_type_dropdown_chosen').click
 end

 def dropdown
   @browser.ul(class: 'chosen-results')
 end

 def test_downgrade_mvp_to_elite
   MSAdmin.goto_payments_page(@client_id)
   MSAdmin.upgrade_or_down_grade_to('Elite')
   check_package_downgraded
   check_client_video_count
   check_coaching_and_evaluation_sessions
 end
end
