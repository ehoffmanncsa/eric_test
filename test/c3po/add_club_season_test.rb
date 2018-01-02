# encoding: utf-8
require_relative '../test_helper'

# TS-289: C3PO Regression
# UI Test: Add Club Season
class AddClubSeasonTest < Minitest::Test
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

  def club_section
    @browser.find_element(:class, 'club_seasons')
  end

  def form
    @browser.find_element(:id, 'club_season_form_container')
  end

  def check_incomplete_form_error_msg
    # open and submit blank form
    club_section.find_element(:class, 'add_icon').click
    form.find_element(:class, 'submit').click
    assert form.find_element(:class, 'errors'), 'Error banner not found'

    error_msg = form.find_element(:class, 'errors').text
    expected_msg = "Club Name cannot be blank.\n" + 'Year must be selected.'
    assert_equal expected_msg, error_msg, "Incorrect error message"

    # close form
    form.find_element(:class, 'cancel_form').click
  end

  def check_added_club
    boxes = club_section.find_elements(:class, 'box_list')
    refute_empty boxes, 'No box show up after added club'
  end

  def check_profile_history
    C3PO.open_athlete_history_popup
    msg = 'No popup after clicking club Stats'
    assert @browser.find_element(:class, 'mfp-content'), msg
  end

  def test_add_club_season
    UIActions.user_login(@email)
    UIActions.goto_edit_profile

    C3PO.goto_athletics
    check_incomplete_form_error_msg
    C3PO.add_club_team
    check_added_club
    check_profile_history
  end
end