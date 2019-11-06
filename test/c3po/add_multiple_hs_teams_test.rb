# encoding: utf-8
require_relative '../test_helper'

# TS-274: C3PO Regression
# UI Test: Add Multiple High School Teams
class AddMultipleHSTeamsTest < Common
  def setup
    super
    email = 'ncsa.automation+e6cc@gmail.com'
    UIActions.user_login(email, 'ncsa1333')
    C3PO.setup(@browser)
  end

  def teardown
    delete_hs_team
    super
  end

  def delete_hs_team
    C3PO.goto_athletics
    while (team && !team.span(class: 'add_icon').present?)
      open_hs_team
      form = @browser.div(id: 'hs_season_edit')
      form.button(text: 'Delete').click
      @browser.alert.ok; sleep 1
    end
  end

  def open_hs_team
    team.click
  end

  def team
    teams_section = @browser.element(class: 'high_school_seasons')
    teams_section.elements(class: 'box_list').first
  rescue
    return false
  end

  def check_added_teams
    teams_section = @browser.element(class: 'high_school_seasons')
    boxes = teams_section.elements(class: 'box_list').to_a
    assert_equal 4, boxes.length, "#{boxes.length} box show up after adding 4 teams"
  end

  def check_profile_history
    C3PO.open_athlete_history_popup
    msg = 'No popup clicking team Stats'
    assert @browser.element(class: 'mfp-content'), msg
  end

  def test_add_multiple_highschool_teams
    C3PO.goto_athletics
    # add 4 HS teams (4 is maximum)
    for i in 1 .. 4
      C3PO.add_hs_team
    end

    check_added_teams
    check_profile_history
  end
end
