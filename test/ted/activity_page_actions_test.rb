# encoding: utf-8
require_relative '../test_helper'

class ActivityPageActionsTest < Common
  def setup
    super
    TED.setup(@browser)
  end

  def teardown
    super
  end

  def test_request_tap_for_accepted_athlete_without_tap_assessment
    UIActions.ted_login
    TED.goto_activity
    Watir::Wait.until { UIActions.find_by_test_id("athlete-activity").present? }

    athlete_row, athlete_row_index = @browser.elements(class: "athlete-activity-row").each_with_index.find do |row, i|
      has_no_tap_assessment = UIActions.find_by_test_id("athlete-activity-row-#{i}-cell-athleteType").text == "-"
      is_accepted = UIActions.find_by_test_id("athlete-activity-row-#{i}-cell-actions").html.include? "more-actions-btn"
      has_no_tap_assessment && is_accepted
    end
    athlete_row.element("data-test-id" => "activity-page-actions-menu-toggle").click
    is_send_message_present = athlete_row.element("data-test-id" => "activity-page-actions-menu-send-message").exists?
    is_request_tap_present = athlete_row.element("data-test-id" => "activity-page-actions-menu-request-tap").exists?

    assert_equal is_send_message_present, true, "Activity Page (athlete tab): cannot send message to accepted athlete"
    assert_equal is_request_tap_present, true, "Activity Page (athlete tab): cannot request tap assessment from athlete without tap assessment"
  end

  def test_no_request_tap_for_accepted_athlete_with_tap_assessment
    UIActions.ted_login
    TED.goto_activity
    Watir::Wait.until { UIActions.find_by_test_id("athlete-activity").present? }

    athlete_row, athlete_row_index = @browser.elements(class: "athlete-activity-row").each_with_index.find do |row, i|
      has_tap_assessment = UIActions.find_by_test_id("athlete-activity-row-#{i}-cell-athleteType").text != "-"
      is_accepted = UIActions.find_by_test_id("athlete-activity-row-#{i}-cell-actions").html.include? "more-actions-btn"
      has_tap_assessment && is_accepted
    end
    athlete_row.element("data-test-id" => "activity-page-actions-menu-toggle").click
    is_send_message_present = athlete_row.element("data-test-id" => "activity-page-actions-menu-send-message").exists?
    is_request_tap_present = athlete_row.element("data-test-id" => "activity-page-actions-menu-request-tap").exists?

    assert_equal is_send_message_present, true, "Activity Page (athlete tab): cannot send message to accepted athlete"
    assert_equal is_request_tap_present, false, "Activity Page (athlete tab): should not be able to request tap assessment from athlete that already has tap assessment"
  end

  def test_no_actions_for_not_accepted_athletes
    UIActions.ted_login
    TED.goto_activity
    Watir::Wait.until { UIActions.find_by_test_id("athlete-activity").present? }

    passes_test = true
    @browser.elements(class: "athlete-activity-row").each_with_index do |row, i|
      is_pending = row.class_name.include? "--is-pending"
      has_more_actions = UIActions.find_by_test_id("athlete-activity-row-#{i}-cell-actions").html.include? "more-actions-btn"
      passes_test = is_pending ? !has_more_actions : has_more_actions
      break if passes_test == false
    end
    assert_equal passes_test, true, "Activity Page (athlete tab): only accepted athletes should see more actions"
  end
end