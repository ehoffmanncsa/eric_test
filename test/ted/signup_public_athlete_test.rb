# encoding: utf-8
require_relative '../test_helper'

# TED-1411
# UI Test: Public Add Athlete to Previously Added Organization

class SignupPublicAthleteTest < Common
  def setup
    super
    TED.setup(@browser)
    MSSetup.setup(@browser)
  end

  def teardown
    super
  end

  def store_names_and_emails
    @athlete_email ||= MakeRandom.email
    @athlete_first_name ||= MakeRandom.first_name
    @athlete_last_name ||= MakeRandom.last_name
    @parent_email = MakeRandom.email
  end

  def fillout_signup_form
    @browser.goto 'https://team-staging.ncsasports.org/teams/awesome-sauce/sign_up'
    Watir::Wait.until { @browser.elements(:tag_name, 'input').any? }

    store_names_and_emails
    fill_inputs

    # agree with the Terms Of Service
    @browser.elements(:type, 'radio').first.click

    # submit
    @browser.button(:type, 'submit').click
    sleep 1
  end

  def fill_out_birthday
    element = @browser.elements(:tag_name, 'input')[3]

    year = Time.now.year - rand(15 .. 18)
    date = (Time.now).strftime("%m-%d")
    birthday = "#{year}-#{date}"

    text = "arguments[0].type='text'"
    TED.modal.execute_script(text, element)

    element.send_keys birthday
  end

  def fill_inputs
    @browser.text_field(:id, 'firstName').set @athlete_first_name
    @browser.text_field(:id, 'lastName').set @athlete_last_name
    @browser.text_field(:id, 'graduationYear').set (Time.now.year + rand(1 .. 3))

    fill_out_birthday

    @browser.text_field(:id, 'phone').set (@athlete_phone ||= MakeRandom.phone_number)
    @browser.text_field(:id, 'zipCode').set (@zip_code ||= MakeRandom.zip_code)
    @browser.text_field(:id, 'email').set @athlete_email
    @browser.text_field(:id, 'parentFirstName').set MakeRandom.first_name
    @browser.text_field(:id, 'parentLastName').set MakeRandom.last_name
    @browser.text_field(:id, 'parentEmail').set @parent_email
    @browser.text_field(:id, 'parentPhone').set MakeRandom.phone_number
  end

  def check_redirect_to_clientrms_password_reset
    Watir::Wait.until { @browser.element(:text, 'Set a Username and Password').present? }

    assert_equal 'https://qa.ncsasports.org/clientrms/user_accounts/edit',
      @browser.url, 'No redirect to Client RMS reset password page'
  end

  def check_redirect_to_clientrms_login
    Watir::Wait.until { @browser.element(:text, 'Student-Athlete Sign In').present? }

    assert_equal 'https://qa.ncsasports.org/clientrms/user_accounts/sign_in',
      @browser.url, 'No redirect to Client RMS login page'
  end

  def assign_new_password
    MSSetup.set_password(@athlete_email)

    Watir::Wait.until { @browser.element(:class, 'welcome').present? }

    assert_equal "Welcome to NCSA, #{@athlete_first_name.capitalize}!",
      @browser.element(:tag_name, 'h1').text,
      'Sign in to Client RMS unsuccessful.'
  end

  def check_athlete_profile_info
    @browser.goto 'https://qa.ncsasports.org/clientrms/profile/my_information/edit'
    Watir::Wait.until { @browser.element(:class, 'subhead').present? }

    assert_equal @browser.element(:id, 'athlete_email').value,
      @athlete_email,
      'Athlete email not present on Edit Client page.'
  end

  def check_athlete_profile_has_parent_email
    assert_equal @browser.element(:id, 'parent1_email').value,
      @parent_email,
      'Parent email not present on Edit Client page.'
  end

  def verify_athlete
    UIActions.ted_login
    TED.goto_roster
    Watir::Wait.until { @browser.element(:tag_name, 'table').present? }

    athlete_row = @browser.element(:text, @athlete_email).parent
    assert athlete_row.present?, 'Athlete not in roster'

    verify_button = athlete_row.button(:text, 'Verify')
    assert verify_button.present?, 'Athlete is not unverified'

    verify_button.click
    TED.modal.button(:text, 'Verify').click
    UIActions.wait_for_modal
    sleep 1

    assert_equal 'Accepted',
      athlete_row.elements(:tag_name, 'td')[4].text,
      'Athlete is not accepted'
  end

  def delete_athlete
    TED.delete_athlete([@athlete_first_name, @athlete_last_name].join(' '))
  end

  def create_ncsa_recruit_from_api
    _post, post_body = RecruitAPI.new.ppost
    @athlete_email = post_body[:recruit][:athlete_email]
    @athlete_first_name = post_body[:recruit][:athlete_first_name]
    @athlete_last_name = post_body[:recruit][:athlete_last_name]
    @athlete_phone = post_body[:recruit][:athlete_phone]
    @zip_code = post_body[:recruit][:zip]
  end

  def login_to_athlete_profile_with_password_reset
    UIActions.user_login(@athlete_email)
    MSSetup.set_password(@athlete_email)

    @browser.element(:class, 'fa-angle-down').click
    navbar = @browser.element(:id, 'secondary-nav-menu')
    navbar.link(:text, 'Logout').click
  end

  def login_to_athlete_profile
    UIActions.user_login(@athlete_email)
  end

  def test_public_new_athlete_sign_up
    fillout_signup_form
    check_redirect_to_clientrms_password_reset
    assign_new_password
    check_athlete_profile_info
    check_athlete_profile_has_parent_email
    verify_athlete
    delete_athlete
  end

  def test_public_existing_athlete_sign_up
    create_ncsa_recruit_from_api
    login_to_athlete_profile_with_password_reset
    fillout_signup_form
    check_redirect_to_clientrms_login
    login_to_athlete_profile
    check_athlete_profile_info
    verify_athlete
    delete_athlete
  end
end
