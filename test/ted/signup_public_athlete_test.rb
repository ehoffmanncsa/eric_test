# encoding: utf-8
require_relative '../test_helper'

# TED-1411
# UI Test: Public Add Athlete to Previously Added Organization

class SignupPublicAthleteTest < Common
  def setup
    super
    TED.setup(@browser)
  end

  def teardown
    super
  end

  def store_names_and_emails
    @athlete_email ||= MakeRandom.email
    @athlete_first_name ||= FFaker::Name.first_name
    @athlete_last_name ||= FFaker::Name.last_name
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

  def fill_inputs
    inputs = @browser.elements(:tag_name, 'input').to_a

    inputs[0].send_keys(@athlete_first_name)
    inputs[1].send_keys(@athlete_last_name)
    inputs[2].send_keys(Time.now.year + 1)

    birth_year = Time.now.year - 15
    inputs[3].send_keys("04/01/#{birth_year}")
    inputs[4].send_keys(@zip_code || FFaker::AddressUS.zip_code)
    inputs[5].send_keys(@athlete_phone || FFaker::PhoneNumber.short_phone_number)
    inputs[6].send_keys(@athlete_email)
    inputs[7].send_keys(FFaker::Name.first_name)
    inputs[8].send_keys(FFaker::Name.last_name)
    inputs[9].send_keys(@parent_email)
    inputs[10].send_keys(FFaker::PhoneNumber.short_phone_number)
  end

  def check_redirect_to_clientrms
    Watir::Wait.until { @browser.element(:text, 'Set a Username and Password').present? }

    assert_equal 'https://qa.ncsasports.org/clientrms/user_accounts/edit',
      @browser.url, 'No redirect to Client RMS'
  end

  def assign_new_password
    @browser.text_field(:id, "user_account_username").set(random_username)

    @browser.text_field(:id, 'user_account_password').set('ncsa')
    @browser.text_field(:id, 'user_account_password_confirmation').set('ncsa')
    @browser.button(:type, 'submit').click

    Watir::Wait.until { @browser.element(:class, 'welcome').present? }

    assert_equal "Welcome to NCSA, #{@athlete_first_name.capitalize}!",
      @browser.element(:tag_name, 'h1').text,
      'Sign in to Client RMS unsuccessful.'
  end

  def random_username
    # need to reset username because doesn't accept usernames with '+' in them
    MakeRandom.name + MakeRandom.number(3).to_s
  end

  def check_athlete_profile_info
    @browser.goto 'https://qa.ncsasports.org/clientrms/profile/my_information/edit'
    Watir::Wait.until { @browser.element(:class, 'subhead').present? }

    assert_equal @browser.element(:id, 'athlete_email').value,
      @athlete_email,
      'Athlete email not present on Edit Client page.'
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

  def test_public_new_athlete_sign_up
    fillout_signup_form
    check_redirect_to_clientrms
    assign_new_password
    check_athlete_profile_info
    verify_athlete
    delete_athlete
  end

  def test_public_existing_athlete_sign_up
    create_ncsa_recruit_from_api
    fillout_signup_form
    check_redirect_to_clientrms
    assign_new_password
    check_athlete_profile_info
    verify_athlete
    delete_athlete
  end
end
