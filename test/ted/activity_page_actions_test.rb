# encoding: utf-8
require_relative '../test_helper'

# TS-561: TED Regression
# UI Test: Verify activity page ellipses actions

=begin
  This test uses coach Eric of the Bears organization.
  We navigate to the activity page, and we want to make sure that each athlete
  row has the appropriate actions based off of the athlete's profile.

  - If an athlete's status is 'accepted', and *has not* taken the TAPS assessment:
    We expect the ellipses to be present
    AND we expect both "Send Message" and "Request TAP" to be dropdown menu options

  - If an athlete's status is 'accepted', but *has* taken the TAPS assessment:
    We expect the ellipses to be present
    AND we expect the "Send Message" option, but *not* the "Request TAP" option

  - If an athlete's status is *not* 'accepted':
    We expect the ellipses to *not* be present
=end

class ActivityPageActionsTest < Common
  def setup
    super
    TED.setup(@browser)

    UIActions.ted_login "coacheric.ted@gmail.com", "ncsa"
    TED.goto_activity
    Watir::Wait.until { UIActions.find_by_test_id("athlete-activity").present? }
  end

  def teardown
    super
  end

  def test_request_tap_for_accepted_athlete_without_tap_assessment
    athlete_row, athlete_row_index = @browser.elements(class: "athlete-activity-row").each_with_index.find do |row, i|
      has_no_tap_assessment = UIActions.find_by_test_id("athlete-activity-row-#{i}-cell-athleteType").text == "-"
      is_accepted = UIActions.find_by_test_id("athlete-activity-row-#{i}-cell-actions").html.include? "more-actions-btn"
      has_no_tap_assessment && is_accepted
    end
    athlete_row.element("data-test-id" => "activity-page-actions-menu-toggle").click
    # TODO: We can probably update our test-ids to avoid grabbing the dropdown menu
    dropdown_menu = @browser.element(:class => "dropdown-menu__menu--is-open")

    failures = []
    failures << "Send message option not found" unless dropdown_menu.element("data-test-id" => "activity-page-actions-menu-send-message").exists?
    failures << "Request tap assessment option not found" unless dropdown_menu.element("data-test-id" => "activity-page-actions-menu-request-tap").exists?

    assert_empty failures
  end

  def test_no_request_tap_for_accepted_athlete_with_tap_assessment
    athlete_row, athlete_row_index = @browser.elements(class: "athlete-activity-row").each_with_index.find do |row, i|
      has_tap_assessment = UIActions.find_by_test_id("athlete-activity-row-#{i}-cell-athleteType").text != "-"
      is_accepted = UIActions.find_by_test_id("athlete-activity-row-#{i}-cell-actions").html.include? "more-actions-btn"
      has_tap_assessment && is_accepted
    end
    athlete_row.element("data-test-id" => "activity-page-actions-menu-toggle").click
    # TODO: We can probably update our test-ids to avoid grabbing the dropdown menu
    dropdown_menu = @browser.element(:class => "dropdown-menu__menu--is-open")

    failures = []
    failures << "Send message option not found" unless dropdown_menu.element("data-test-id" => "activity-page-actions-menu-send-message").exists?
    failures << "Request tap assessment found" if dropdown_menu.element("data-test-id" => "activity-page-actions-menu-request-tap").exists?

    assert_empty failures
  end

  def test_no_actions_for_not_accepted_athletes
    passes_test = true
    @browser.elements(class: "athlete-activity-row").each_with_index do |row, i|
      is_pending = row.class_name.include? "--is-pending"
      has_more_actions = UIActions.find_by_test_id("athlete-activity-row-#{i}-cell-actions").html.include? "more-actions-btn"
      passes_test = is_pending ? !has_more_actions : has_more_actions
      binding.pry if !passes_test
      break if !passes_test
    end
    assert_equal passes_test, true, "Activity Page (athlete tab): only accepted athletes should see more actions"
  end
end
