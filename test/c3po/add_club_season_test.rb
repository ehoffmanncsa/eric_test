# encoding: utf-8
require_relative '../test_helper'

# TS-289: C3PO Regression
# UI Test: Add Club Season
class AddClubSeasonTest < Common
  def setup
    super

    # This test case is specifically for Football premium
    # Attempt to use a static MVP client
    email = 'ncsa.automation+e6cc@gmail.com'

    C3PO.setup(@browser)
    UIActions.user_login(email, 'ncsa1333')
  end

  def teardown
    delete_club_season
    @browser.close
  end

  def delete_club_season
    C3PO.goto_athletics
    club_box.click
    form.button(text: 'Delete').click
    @browser.alert.ok
    sleep 2
  end

  def club_section
    @browser.element(class: 'club_seasons')
  end

  def club_box
    club_section.lis(class: 'box_list').first
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
    C3PO.goto_athletics
    check_incomplete_form_error_msg
    C3PO.add_club_team
    check_added_club
    check_profile_history
  end
end
