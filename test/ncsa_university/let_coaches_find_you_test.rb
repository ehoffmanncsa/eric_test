# encoding: utf-8
require_relative '../test_helper'

# TS-201: NCSA University Regression
# UI Test: let Coaches Find You Milestone. Need to have an empty gpa, weight and stats fields or test 
# will not run.
class LetCoachesFindYou < Common
  def setup
    super

    C3PO.setup(@browser)
  end

  def teardown
    super
  end

  def get_started
    selection = @browser.link(:text, 'I don’t know if competing in football at the college level is realistic.').click
    #@browser.element(:class, %w[button--clear-dark]).click
    sleep 2
  end

  def select_high_school
    # select state
    dropdown = @browser.element(:id, 'profile_data_high_school_id')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Lane Tech High School'
    end
  end

  def select_gpa
    # select state
    dropdown = @browser.element(:id, 'profile_data_gpa')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == '3.7'
    end
  end


  def click_next
    @browser.element(:class, 'button--wide').click
  end

  def select_position
    # select state
    dropdown = @browser.element(:id, 'profile_data_primary_position_id')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Quarterback'
    end
  end

  def select_height
    # select state
    dropdown = @browser.element(:id, 'profile_data_height')
    options = dropdown.elements(:tag_name, 'option').to_a
    options.shift
    options.sample.click
    sleep 1
  end

  def enter_weight
    # select state
    @browser.element(:id, 'profile_data_weight').send_keys '250'
    sleep 1
  end

  def enter_stats
    # select state
    @browser.element(:id, 'profile_data_measurables[40 Yard Dash]').send_keys '5.0'
    @browser.element(:id, 'profile_data_measurables[5-10-5 Shuttle]').send_keys '4.6'
    @browser.element(:id, 'profile_data_measurables[Bench Press]').send_keys '500'
  end

  def select_ncsa
    selection = @browser.link(:text, "I'm very familiar and am ready to get started!").click
    sleep 1
  end

  def select_help
    selection = @browser.element(:id, 'onboarding_drill_customize_coaches_notice_me').click
    sleep 1
  end

  def click_next2
    @browser.element(:class, 'button--secondary button--wide mg-top-1').click
  end

  def enter_club
    @browser.element(:id, 'club_data_club_team_type_club').click
    sleep 1
  end

   def enter_club2
    @browser.element(:name, 'club_data[name]').send_keys 'Test Club'
    sleep 1
    @browser.element(:id, 'club_data_phone').send_keys '773-123-4567'
    sleep 1
    @browser.element(:id, 'club_data_email').send_keys 'club@yopmail.com'
    sleep 1
  end

  def select_type_coach
    # select state
    dropdown = @browser.element(:id, 'club_data_coach_type')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Club Coach'
    end
  end

  def click_no
    @browser.element(:id, 'club_data_club_share_activity_false').click
  end

  def verify_drill_completed

    UIActions.goto_ncsa_university

    sleep 2
    timeline_history = @browser.element(:class, 'timeline-history')
    milestone = timeline_history.elements(:css, 'li.milestone.point.complete').last
    title = milestone.element(:class, 'title').text
    assert_equal 'Let Coaches Find You', title, "#{title} - Expected: Let Coaches Find You"
  end

  def test_do_drill
  
    email = 'test6170@yopmail.com'
    UIActions.user_login(email)

    UIActions.goto_ncsa_university

    milestone = @browser.link(:text, 'Start getting noticed!').click
    @browser.element(:class, 'button--wide').click

    
    get_started
    select_high_school
    select_gpa
    click_next
    select_position
    click_next
    select_height
    enter_weight
    click_next
    enter_stats
    click_next
    select_ncsa
    select_help
    click_next2
    enter_club
    enter_club2
    select_type_coach
    click_no
    click_next2
    verify_drill_completed
  end
end
