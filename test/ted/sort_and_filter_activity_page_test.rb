# encoding: utf-8
require_relative '../test_helper'

# TS-561: TED Regression
# UI Test: Verify activity page sort and filter functionality

=begin
  This test uses coach Eric of the Bears organization.
  We navigate to the activity page, and we want to make sure a coach can filter
  their athletes, and/or sort their athletes by the columns in the table.
  - This test verifies that the favorites column sorts as expected (by number of favorites, ascending order)
  - This test verifies the default sort column (by last name, ascending order)
  - This test verifies that the sort icon renders correctly (i.e. points up for ascending and down for descending)
  - This test verifies that a coach can filter athletes by team
=end

class SortAndFilterActivityPageTest < Common
  def setup
    super
    TED.setup(@browser)

    UIActions.ted_login "tedc@yopmail.com", "ncsa"
    TED.goto_activity
    Watir::Wait.until { UIActions.find_by_test_id("athlete-activity").present? }
  end

  def teardown
    super
  end

  def assert_active_sort_icon(key)
    header_cell = UIActions.find_by_test_id("athlete-activity-header-cell-#{key}")
    sort_icon = header_cell.children.to_a.find { |node| node.class_name.include? 'sort-icon' }
    assert_includes sort_icon.class_name, "is-active", "Activity Page (athlete tab): header cell icon for #{key} should be active"
    assert_includes sort_icon.class_name, "is-ascending", "Activity Page (athlete tab): header cell icon for #{key} should be ascending"
  end

  def assert_table_sorted_by(key)
    # TODO: is there a better way to do this? this normally wouldn't be a big problem, but we are
    # testing against an org with 300+ students, so this takes a little while...
    data = @browser.elements(class: "athlete-activity-row").each_with_index.map do |row, i|
      yield(UIActions.find_by_test_id("athlete-activity-row-#{i}-cell-#{key}"))
    end
    assert_equal data, data.sort, "Activity Page (athlete tab): not properly sorted by #{key}"
  end

  def test_athletes_default_sort
    # table should sort by name (ascending) by default
    assert_active_sort_icon("name")
    assert_table_sorted_by("name") do |node|
      # get cell text, split name, grab last name, downcase to remove any inconsistencies
      node.text.split(' ')[1].downcase
    end
  end

  def test_athletes_sort_by_favorites
    UIActions.find_by_test_id("athlete-activity-header-cell-nFavorites").click
    assert_active_sort_icon("nFavorites")
    assert_table_sorted_by("nFavorites") { |node| Integer(node.text) }
  end

  def test_filter_by_team
    team_name = "ncsA11"
    UIActions.find_by_test_id("activity-page-team-dropdown").click
    UIActions.find_by_test_id("activity-page-team-dropdown-item-#{team_name}").click

    contains_athlete_not_in_team = false
    @browser.elements(class: "athlete-activity-row").each_with_index do |_, i|
      athlete_details_text = UIActions.find_by_test_id("athlete-activity-row-#{i}-cell-name").text
      team_details_text = athlete_details_text.split("\n")[1]
      contains_athlete_not_in_team = !team_details_text.include?(team_name)
      break if contains_athlete_not_in_team
    end
    assert_equal contains_athlete_not_in_team, false, "Activity Page: not filtering by teams correctly"
  end
end