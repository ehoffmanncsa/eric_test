# encoding: utf-8
require_relative '../test_helper'

class DashboardActiveCollegesWidgetTest < Common
  def setup
    super
    TED.setup(@browser)
  end

  def teardown
    super
  end

  def test_sport_switcher_on_organization_with_multiple_sports
    UIActions.ted_login "coacheric.ted@gmail.com", "ncsa"
    Watir::Wait.until { @browser.element(class: "dashboard-page").present? }

    failures = []

    sport_switcher = UIActions.find_by_test_id "app-sport-switcher"
    failures << "Sport switcher wasn't present for organization with multiple sports" unless sport_switcher.exists?

    sport_switcher.click
    # TODO: We can probably update our test-ids to avoid grabbing the dropdown menu
    dropdown_menu = @browser.element(class: "dropdown-menu__menu--is-open")
    menu_items = dropdown_menu.elements(class: "dropdown-menu__item")
    failures << "Sport switcher contains 1 or less sports" unless menu_items.length > 1

    assert_empty failures
  end

  def test_sport_switcher_on_organization_with_only_one_sport
    UIActions.ted_login "arthurgallagher@yopmail.com", "ncsa"
    Watir::Wait.until { @browser.element(class: "dashboard-page").present? }

    sport_switcher = UIActions.find_by_test_id "app-sport-switcher"
    assert_equal sport_switcher.exists?, false, "Sport switcher was present for organization with only one sport"
  end

  def test_active_college_card
    UIActions.ted_login "coacheric.ted@gmail.com", "ncsa"
    Watir::Wait.until { @browser.element(class: "dashboard-page").present? }


    active_college_card = @browser.element(class: "active-college-card")
    college_name = active_college_card.element(class: "active-college-card__name").text
    active_college_card.click

    college_profile = @browser.element(class: "college-profile")
    # TODO: Add test-id for name in college profile
    college_name_on_profile = college_profile.element(tag_name: "h2").text

    assert_equal college_name, college_name_on_profile, "Name on active college card and name of college on college page do not match"
  end

  def test_active_colleges_widget_links
    UIActions.ted_login "coacheric.ted@gmail.com", "ncsa"
    Watir::Wait.until { @browser.element(class: "dashboard-page").present? }

    widget_wrapper = @browser.element(class: "active-collges-widget")
    widget_wrapper.link(text: "Search all").click
    current_url = @browser.url.split('/')[-1]

    assert_equal current_url, "colleges", "Search all link should take you to colleges page"
  end
end
