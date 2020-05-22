# encoding: utf-8
require_relative '../test_helper'

# TS-289: C3PO Regression
# UI Test: Add Club Season
class AddClubSeasonTest < Common
  def setup
    super

    C3PO.setup(@browser)
  end

  def teardown
    @browser.close
  end

  def club_section
    @browser.element(class: 'club_seasons')
  end

  def form
    @browser.element(id: 'club_season_form_container')
  end

  def check_incomplete_form_error_msg
    # open and submit blank form
    club_section.element(class: 'add_icon').click
    form.button(class: 'submit').click
    assert form.element(class: 'errors'), 'Error banner not found'

    error_msg = form.element(class: 'errors').text
    expected_msg = "Club Name cannot be blank.\n" + 'Year must be selected.'
    assert_equal expected_msg, error_msg, "Incorrect error message"

    # close form
    form.element(class: 'cancel_form').click
  end

  def check_added_club
    boxes = club_section.elements(tag_name: 'li').to_a
    refute_empty boxes, 'No box show up after added club'
  end

  def check_profile_history
    C3PO.open_athlete_history_popup
    msg = 'No popup after clicking club Stats'
    assert @browser.element(class: 'mfp-content'), msg
  end

  def test_add_club_season
    email = 'test0b73@yopmail.com'
    UIActions.user_login(email)
    sleep 5
    UIActions.goto_edit_profile

    C3PO.goto_athletics
    check_incomplete_form_error_msg
    C3PO.add_club_team
    check_added_club
    check_profile_history
  end
end
