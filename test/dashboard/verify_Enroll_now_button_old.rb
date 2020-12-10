# frozen_string_literal: true

require_relative '../test_helper'

# TS-601
# UI Test: Verify enroll button is dislayed on dashboard for activated client
class VerifyEnrollNowButton < Common
  def setup
    super
    MSSetup.setup(@browser)

    enroll_yr = 'sophomore'
    @clientrms = Default.env_config['clientrms']

    _post, post_body = RecruitAPI.new(enroll_yr).ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    @recruit_name = post_body[:recruit][:athlete_first_name]

    UIActions.user_login(@recruit_email)
    MSSetup.set_password
  end

  def get_activated
    MSSetup.goto_offerings
    sleep 5
    url = 'https://qa.ncsasports.org/clientrms/'
    @browser.goto url
    sleep 5
  end

  def verify_Enroll_button_is_displayed_on_dashboard
    close_icon =@browser.element(class: "svg-inline--fa", "data-icon" => "times")
    close_icon.click
    sleep 1
    # here verifying after clicking enroll button user is naviagted to pos page
    enroll_button = @browser.element('data-test-id': 'enroll-button')
    assert @browser.element('data-test-id': 'enroll-button').present?, 'Enroll button is not displayed on dashboard'
    enroll_button.click
    sleep 1
    failures = []
    failures << 'Failed to navigate to POS page' unless client_is_at_POS_page?
    assert_empty failures
  end

  def client_is_at_POS_page?
    @browser.url.include? 'clientrms/membership/offerings?registrationSrc=enrollNowPOS'
  end

  def test_verify_enroll_now_button
      get_activated
      verify_Enroll_button_is_displayed_on_dashboard
   end
end
