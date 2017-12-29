# encoding: utf-8
require_relative '../test_helper'

# TS-292: C3PO Regression
# UI Test: Add High School Team with Stats
class AddHSTeamWithStatsTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]
    
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    C3PO.setup(@browser)

    POSSetup.setup(@ui)
    POSSetup.buy_package(@email, 'elite')
  end

  def teardown
    @browser.quit
  end

  def check_stats_in_popup
    @browser.find_element(:class, 'button--primary').click; sleep 1

    UIActions.wait(40).until { @browser.find_element(:id, 'athletic-section').displayed? }
    history_section = @browser.find_element(:id, 'athletic-section')
    history_section.location_once_scrolled_into_view; sleep 1

    stat = history_section.find_elements(:tag_name, 'li').first
    stat.find_element(:class, 'mg-right-1').click; sleep 1
    popup = @browser.find_element(:class, 'mfp-content')
    headers = []
    popup.find_elements(:tag_name, 'h6').each { |e| headers << e.text.downcase }

    headers.join(',')
  end

  def test_add_hs_team_with_stats
    UIActions.user_login(@email)
    UIActions.goto_edit_profile

    C3PO.goto_athletics
    C3PO.add_hs_team
    C3PO.open_hs_team
    stat_headers = C3PO.add_stats_hs_team
    popup_headers = check_stats_in_popup
    assert_includes popup_headers, stat_headers, 'Stats headers not found'
  end
end