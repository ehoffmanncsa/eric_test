# encoding: utf-8
require_relative '../test_helper'

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
