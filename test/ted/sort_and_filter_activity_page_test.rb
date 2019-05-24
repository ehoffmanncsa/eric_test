# encoding: utf-8
require_relative '../test_helper'

class SortAndFilterActivityPageTest < Common
  def setup
    super
    TED.setup(@browser)
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

  def test_default_sort_athletes
    UIActions.ted_login
    TED.goto_activity
    Watir::Wait.until { UIActions.find_by_test_id("athlete-activity").present? }

    # table should sort by name (ascending) by default
    assert_active_sort_icon("name")
    assert_table_sorted_by("name") do |node|
      # get cell text, split name, grab last name, downcase to remove any inconsistencies
      node.text.split(' ')[1].downcase
    end
  end

  def test_sort_by_favorites_athletes
    UIActions.ted_login
    TED.goto_activity
    Watir::Wait.until { UIActions.find_by_test_id("athlete-activity").present? }

    UIActions.find_by_test_id("athlete-activity-header-cell-nFavorites").click
    assert_active_sort_icon("nFavorites")
    assert_table_sorted_by("nFavorites") { |node| Integer(node.text) }
  end
end