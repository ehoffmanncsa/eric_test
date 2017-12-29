# encoding: utf-8
require_relative '../test_helper'

# TS-274: C3PO Regression
# UI Test: Add Multiple High School Teams
class AddMultipleHSTeamsTest < Minitest::Test
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

  def check_added_teams
    teams_section = @browser.find_element(:class, 'high_school_seasons')
    boxes = teams_section.find_elements(:class, 'box_list')
    assert_equal 4, boxes.length, "#{boxes.length} box show up after adding 4 teams"
  end

  def check_profile_history
    @browser.find_element(:class, 'button--primary').click
    history_section = @browser.find_element(:id, 'athletic-section')
    list = history_section.find_elements(:tag_name, 'li')
    assert_equal 4, list.length, "#{list.length} teams in history - Expected 4"

    list.sample.find_element(:class, 'mg-right-1').click; sleep 1
    msg = 'No popup clicking team Stats'
    assert @browser.find_element(:class, 'mfp-content'), msg
  end

  def test_add_multiple_highschool_teams
    UIActions.user_login(@email)
    UIActions.goto_edit_profile

    C3PO.goto_athletics
    # add 4 HS teams (4 is maximum)
    for i in 1 .. 4
      C3PO.add_hs_team
    end

    check_added_teams
    check_profile_history
  end
end
