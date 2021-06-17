# frozen_string_literal: true

require_relative '../test_helper'

# Dashboard Regression
# UI Test: Enroll as a Elite User - Sophomore, 6 month payments, then sign up for a Welcome Workshop
# Verify Welcome Workshop displays on dashboard after signing up

class WelcomeWorkshopPaymentsTest < Common
  def setup
    super

    enroll_yr = 'sophomore'
    @package = 'elite'
    @clientrms = Default.env_config['clientrms']

    _post, post_body = RecruitAPI.new(enroll_yr).ppost
    recruit_email = post_body[:recruit][:athlete_email]

    UIActions.user_login(recruit_email)
    MSTestTemplate.setup(@browser, recruit_email, @package)
  end

  def teardown
    super
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

  def test_welcome_workshop_signup_payments
    MSTestTemplate.get_enrolled

    check_redirected_to_welcome_workshop
    signup_welcome_workshop
    verify_signed_up
    UIActions.goto_dashboard
    sleep 2
    verify_dashboard_welcome_workshop
  end
end
