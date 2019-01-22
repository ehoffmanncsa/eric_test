# encoding: utf-8
require_relative '../test_helper'

# TS-274: C3PO Regression
# UI Test: Add Multiple High School Teams
class AddMultipleHSTeamsTest < Common
  def setup
    super

    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]

    C3PO.setup(@browser)
    MSSetup.setup(@browser)

    MSSetup.buy_package(@email, 'elite')
  end

  def teardown
    super
  end

  def check_added_teams
    teams_section = @browser.element(:class, 'high_school_seasons')
    boxes = teams_section.elements(:class, 'box_list').to_a
    assert_equal 4, boxes.length, "#{boxes.length} box show up after adding 4 teams"
  end

  def check_profile_history
    C3PO.open_athlete_history_popup
    msg = 'No popup clicking team Stats'
    assert @browser.element(:class, 'mfp-content'), msg
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
