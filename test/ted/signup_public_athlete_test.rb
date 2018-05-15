# encoding: utf-8
require_relative '../test_helper'

# TED-1411
# UI Test: Public Add Athlete to Previously Added Organization

class SignupPublicAthleteTest < Common
  def setup
    super
    TED.setup(@browser)

    set_names
  end

  def teardown
    super
  end

  def set_names
    @athlete_first_name = FFaker::Name.first_name
    @athlete_last_name = FFaker::Name.last_name
    @athlete_email = @athlete_first_name[0] + @athlete_last_name + "@yopmail.com"
    @parent_first_name = FFaker::Name.first_name
    @parent_last_name = FFaker::Name.last_name
    @parent_email = @parent_first_name[0] + @parent_last_name + "@yopmail.com"
  end

  def fillout_signup_form
    @browser.goto 'https://team-staging.ncsasports.org/teams/awesome-sauce/sign_up'
    Watir::Wait.until { @browser.elements(:tag_name, 'input').any? }

    fill_inputs

    # agree with the Terms Of Service
    @browser.elements(:type, 'radio').first.click

    # submit
    @browser.button(:type, 'submit').click
    sleep 1
  end

  def fill_inputs
    inputs = @browser.elements(:tag_name, 'input').to_a

    inputs[0].send_keys @athlete_first_name
    inputs[1].send_keys @athlete_last_name
    inputs[2].send_keys Time.now.year + 1

    birth_year = Time.now.year - 15
    inputs[3].send_keys "04/01/#{birth_year}"
    inputs[4].send_keys FFaker::AddressUS.zip_code
    inputs[5].send_keys FFaker::PhoneNumber.short_phone_number
    inputs[6].send_keys @athlete_email
    inputs[7].send_keys @parent_first_name
    inputs[8].send_keys @parent_last_name
    inputs[9].send_keys @parent_email
    inputs[10].send_keys FFaker::PhoneNumber.short_phone_number
  end

  def check_redirect_to_clientrms
    Watir::Wait.until { @browser.element(:text, 'Set a Username and Password').present? }

    assert_equal 'https://qa.ncsasports.org/clientrms/user_accounts/edit',
      @browser.url, 'No redirect to Client RMS'
  end

  def assign_new_password
    @browser.element(:id, 'user_account_password').send_keys 'ncsa'
    @browser.element(:id, 'user_account_password_confirmation').send_keys 'ncsa'
    @browser.button(:type, 'submit').click

    Watir::Wait.until { @browser.element(:class, 'welcome').present? }

    assert_equal "Welcome to NCSA, #{@athlete_first_name}!",
      @browser.element(:tag_name, 'h1').text,
      'Sign in to Client RMS unsuccessful.'
  end

  def check_athlete_profile_info
    @browser.goto 'https://qa.ncsasports.org/clientrms/profile/my_information/edit'
    Watir::Wait.until { @browser.element(:class, 'subhead').present? }

    assert_equal @browser.element(:id, 'athlete_email').value,
      @athlete_email,
      'Athlete email not present on Edit Client page.'
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

    assert_equal 'Accepted',
      athlete_row.elements(:tag_name, 'td')[4].text,
      'Athlete is not accepted'
  end

  def delete_athlete
    TED.delete_athlete([@athlete_first_name, @athlete_last_name].join(' '))
  end

  def test_public_athlete_sign_up
    fillout_signup_form
    check_redirect_to_clientrms
    assign_new_password
    check_athlete_profile_info
    verify_athlete
    delete_athlete
  end
end
