# encoding: utf-8
require_relative '../test_helper'

# UI Test: Sign up and go through onboarding
class SignupOnboardingTest < Common
  def setup
    super

    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email] # 'ncsa.automation+c1b9@gmail.com'
    @firstname = post_body[:recruit][:athlete_first_name] # 'Jacquetta'

    UIActions.user_login(@email)
    C3PO.setup(@browser)
    MSSetup.setup(@browser)
    MSSetup.set_password
  end

  def test_signup_goes_to_onboarding
    failures = []
    failures << "Client didn't land on onboarding after signup" unless client_is_at_onboarding?
    failures << "Onboarding failed to greet new client" unless onboarding_greets_client?
    assert_empty failures
  end

  def test_closing_onboarding
    close_onboarding

    failures = []
    failures << "Failed to close onboarding successfully" unless client_is_at_dashboard?
    assert_empty failures
  end

  private

  def close_onboarding
    close_button = UIActions.find_by_test_id("onboarding-close-icon")
    close_button.click
    confirm_button = @browser.link(text: "Yes, Exit for Now")
    confirm_button.click
    sleep 2
  end

  def client_is_at_onboarding?
    @browser.url.include? "/clientrms/onboarding"
  end

  def client_is_at_dashboard?
    @browser.element(tag_name: "body").classes.include? "digital_dashboard"
  end

  def onboarding_greets_client?
    title = @browser.element(tag_name: "h1")
    title.text.include? "Welcome to NCSA, #{@firstname}"
  end
end
