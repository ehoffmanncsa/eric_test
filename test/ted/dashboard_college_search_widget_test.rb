# encoding: utf-8
require_relative '../test_helper'

class DashboardCollegeSearchWidgetTest < Common
  def setup
    super
    TED.setup(@browser)

    UIActions.ted_login "coacheric.ted@gmail.com", "ncsa"
    Watir::Wait.until { @browser.element(class: "dashboard-page").present? }
  end

  def teardown
    super
  end

  def test_college_name_maintained_on_search
    college_name = "Purdue"
    search_input = @browser.element(class: "college-search-widget__search-input")
    search_input.send_keys(college_name)

    # TODO: Add test-id for submit button on college search widget
    @browser.button(text: "Search").click

    current_path = @browser.url.split('/')[-1]
    assert_equal current_path, "colleges?searchQuery=#{college_name}", "College name was not maintained when searching from the dashboard"
  end

  def test_state_selection_maintained_on_search
    state_code = "OH"
    widget = @browser.element(class: "college-search-widget")
    widget.element(class: state_code).click
    # TODO: Add test-id for submit button on college search widget
    @browser.button(text: "Search").click

    current_path = @browser.url.split('/')[-1]
    assert_equal current_path, "colleges?searchQuery=&stateCode[]=#{state_code}", "Selected states were not maintained when searching from the dashboard"
  end
end