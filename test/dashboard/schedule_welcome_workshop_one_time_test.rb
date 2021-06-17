# frozen_string_literal: true

require_relative '../test_helper'

# Dashboard Regression
# UI Test: Enroll as a Champion User - Senior, one-time payment, then sign up for a Welcome Workshop
# Verify Welcome Workshop displays on dashboard after signing up

class WelcomeWorkshopOneTimeTest < Common
  def setup
    super

    enroll_yr = 'senior'
    @package = 'champion'
    @clientrms = Default.env_config['clientrms']

    post, post_body = RecruitAPI.new(enroll_yr).ppost
    recruit_email = post_body[:recruit][:athlete_email]
    @posclient_id = post['client_id']
    MSAdmin.setup(@browser)

    UIActions.user_login(recruit_email)
    sleep 2
    MSTestTemplate.setup(@browser, recruit_email, @package)
  end

  def teardown
    super
  end

  def select_one_month_payment
    @browser.element('data-test-id': 'plan-month-button-1').click
    sleep 2
  end

  def select_champion
    @browser.element('data-test-id': 'package-card-select-Champion').click
    sleep 2
  end

  def accept_agreement
    @browser.element(text: 'I Accept').click
  end

  def check_redirected_to_welcome_workshop
    # this check is only for premium enrollment - PREM-4933
    current_url = @browser.url
    failure_msg = "User is not redirected to Welcome Workshop- current url is #{current_url}"
    assert_includes current_url, 'education/search_classes?title=welcome+workshop', failure_msg
  end

  def signup_welcome_workshop
    @browser.button(value: 'Sign Up').click
    sleep 2
  end

  def verify_signed_up
    failure = []
    failure << 'Athlete is not signed up for Welcome Workshop' unless @browser.html.include? 'Signed Up'
    assert_empty failure
  end

  def verify_dashboard_welcome_workshop
    failure = []
    failure << 'Welcome Workshop header is not displayed' unless @browser.html.include? 'Your Next Recruiting Session'
    failure << 'Welcome Workshop is not displayed' unless @browser.html.include? 'Welcome Workshop'
    assert_empty failure
  end

  def test_welcome_workshop_signup_one_time
    MSSetup.set_password
    MSSetup.goto_offerings
    sleep 2
    MSAdmin.update_point_of_sale_event(@posclient_id)
    sleep 2
    MSSetup.goto_offerings

    select_one_month_payment
    select_champion
    accept_agreement

    MSFinish.setup_billing_enroll_now

    check_redirected_to_welcome_workshop
    signup_welcome_workshop
    verify_signed_up
    UIActions.goto_dashboard
    sleep 2
    verify_dashboard_welcome_workshop
  end
end
