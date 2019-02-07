# encoding: utf-8
require_relative '../test_helper'

# Clive -
# UI Test: Add an athletic event and verify it displays.

=begin
  Run the athletic event api
  then log into the app and verify eent displays
=end

class CLFEAddAthleticEventTest < Common
  def setup
    super
    COACHLIVE.setup(@browser)
  end

  def teardown
    super
  end

  def display_upcoming_events
    # display all upcoming events
    upcoming = @browser.element(:text, 'Upcoming')
    view_all = upcoming.element(:class, 'events/upcoming').click
  end

  def form
    @browser.element(:id, 'club_season_form_container')
  end

  def check_incomplete_form_error_msg
    # open and submit blank form
    club_section.element(:class, 'add_icon').click
    form.button(:class, 'submit').click
    assert form.element(:class, 'errors'), 'Error banner not found'

    error_msg = form.element(:class, 'errors').text
    expected_msg = "Club Name cannot be blank.\n" + 'Year must be selected.'
    assert_equal expected_msg, error_msg, "Incorrect error message"

    # close form
    form.element(:class, 'cancel_form').click
  end

  def check_added_club
    boxes = club_section.elements(:tag_name, 'li').to_a
    refute_empty boxes, 'No box show up after added club'
  end

  def check_profile_history
    C3PO.open_athlete_history_popup
    msg = 'No popup after clicking club Stats'
    assert @browser.element(:class, 'mfp-content'), msg
  end

  def test_verify_athletic_event
    UIActions.coach_live_login
    display_upcoming_events
  end
end
