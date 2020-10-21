# frozen_string_literal: true

require_relative '../test_helper'

# Coach Regression
# UI Test: Coach Roster Openings Test
# This test will create a roster opening in coach rms and then verify
# the roster opening is displayed in client rms.
class CoachRMSRosterOpeningsTest < Common
  def setup
    super
    @graduation_year = MakeRandom.grad_yr.to_s
    @coach_comments = MakeRandom.lorem_words

    app_name = 'fasttrack'
    @sql = SQLConnection.new(app_name)
    @sql.get_connection
  end

  def teardown
    super
  end

  def select_roster_openings
    user_info = @browser.element(class: 'header__user-info')
    menu = user_info.element(class: 'header__user-info__menu-button').click
    @browser.element(text: 'Roster Openings').click
  end

  def open_positions_select_list
    @browser.element(class: 'chosen-choices').click
  end

  def select_position
    dropdown = @browser.element(class: 'chosen-results')
    options = dropdown.elements(tag_name: 'li').to_a.sample.click
    sleep 1
  end

  def select_grad_year(grad_yr)
    @browser.element(id: 'dk0-combobox').click
    list = @browser.element(id: "dk0-#{grad_yr}").click
  end

  def enter_details
    @browser.element(class: 'text').send_keys @coach_comments
  end

  def create_listing
    @browser.element(text: 'Create Listing').click
    sleep 3
  end

  def open_position_listed
    # gets the postion listed in Open Positions table
    @position = @browser.elements(tag_name: 'td').first.text
  end

  def open_division_select_list
    @browser.element(class: 'chosen-choices').click
  end

  def select_division
    # select NCAA I-AA
    dropdown = @browser.element(class: 'chosen-drop')
    options = dropdown.elements(tag_name: 'li')[1].click
    sleep 1
  end

  def advanced_filters_open
    @browser.element(class: %w[fa fa-caret-down]).click
  end

  def open_state_select_list
    @browser.element(id: 'state_chosen').click
  end

  def select_state
    # select IL to filter
    dropdown = @browser.element(id: 'state_chosen')
    option = dropdown.elements(tag_name: 'li')[17].click
  end

  def click_details
    @browser.element(class: ['m-button', 'button--primary']).click
  end

  def verify_grad_year
    failure = []
    failure << 'Graduation year is not displaying' unless @browser.html.include? @graduation_year.to_s
    assert_empty failure
  end

  def verify_position
    failure = []
    failure << 'Position is not displaying' unless @browser.html.include? @position.to_s
    assert_empty failure
  end

  def verify_coach_comments
    failure = []
    failure << 'Coach comments are not displaying' unless @browser.html.include? @coach_comments
    assert_empty failure
  end

  def update_positions
    # open or closed positions will display on roster opening page,
    # changing to rejected so they do not display
    query = "update roster_openings
              set status = 'REJECTED'
              where coach_sport_id = 137851"
    @sql.exec query
  end

  def test_coach_rms_login
    UIActions.coach_rms_login
    select_roster_openings
    sleep 1
    open_positions_select_list
    select_position
    sleep 1
    select_grad_year(@graduation_year)
    sleep 2
    enter_details
    sleep 2
    create_listing
    sleep 4
    open_position_listed
    sleep 2
    UIActions.coach_rms_logout

    UIActions.user_login('ncsa.automation+38a2@gmail.com')
    UIActions.goto_roster_openings
    open_division_select_list
    sleep 2
    select_division
    sleep 2
    advanced_filters_open
    sleep 2
    open_state_select_list
    sleep 2
    select_state
    sleep 1
    click_details
    sleep 3
    verify_position
    verify_grad_year
    verify_coach_comments
    update_positions
  end
end
