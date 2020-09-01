# frozen_string_literal: true

require_relative '../test_helper'

# Ts-601 MS Regression
# UI Test: Verify the Calendly Meeting can ba accessed from the user profile menu
class RecruitAssessmentMenuTest < Common
  def setup
    super
    MSSetup.setup(@browser)

    enroll_yr = 'junior'
    @clientrms = Default.env_config['clientrms']

    _post, post_body = RecruitAPI.new(enroll_yr).ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    @recruit_name = post_body[:recruit][:athlete_first_name]

    UIActions.user_login(@recruit_email)
    MSSetup.set_password
  end

  def teardown
    super
  end

  def select_from_menu
    @browser.element(class: 'fa-angle-down').click
    navbar = @browser.element(id: 'secondary-nav-menu')
    navbar.link(text: 'Request an Assessment').click
  end

  def select_parent
    @browser.element(text: "I'm a Parent").click
    sleep 3
  end

  def select_athlete
    @browser.element(text: "I'm an Athlete").click
    sleep 3
  end

  def schedule_close
    close = @browser.element(class: 'ncsa-modal-content')
    close.element(class: 'ncsa-close').click
    sleep 1
  end

  def clientrms_sign_out
    @browser.element(class: 'fa-angle-down').click
    navbar = @browser.element(id: 'secondary-nav-menu')
    navbar.link(text: 'Logout').click
  end

  def test_recruit_assessment_from_menu
    UIActions.close_supercharge
    select_from_menu
    select_parent
    schedule_close
    select_from_menu
    select_athlete
    schedule_close
    clientrms_sign_out
  end
end
