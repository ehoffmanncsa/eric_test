# encoding: utf-8
require_relative '../test_helper'

# TED-1429: Test Unverified Coach Actions on the site

class UnverifiedCoachActionsTest < Common
  def setup
    super
    TED.setup(@browser)

    @coach_email = Default.env_config["ted"]["unverified_username"]
    @coach_password = Default.env_config['ted']['unverified_password']
  end

  def teardown
    super
  end

  def set_athlete_attributes
    @athlete_email = MakeRandom.email
    @first_name = FFaker::Name.first_name
    @last_name = FFaker::Name.last_name
    @athlete_name = "#{@first_name} #{@last_name}"
  end

  def add_ted_athlete_through_ui
    open_add_athlete_modal

    # fill out athlete form
    Watir::Wait.until { TED.modal.visible? }
    inputs = TED.modal.elements(:tag_name, 'input').to_a
    inputs[0].send_keys @first_name              # first name
    inputs[1].send_keys @last_name               # last name
    inputs[2].send_keys MakeRandom.grad_yr       # graduation year
    inputs[3].send_keys MakeRandom.number(5)     # zipcode
    inputs[4].send_keys @athlete_email           # email
    inputs[5].send_keys MakeRandom.number(10)    # phone
    TED.modal.button(:text, 'Add Athlete').click

    UIActions.wait_for_modal

    # make sure athlete name shows up after added
    assert (@browser.element(:text, @athlete_name).present?), "Cannot find newly added Athlete #{@athlete_name}"
  end

  def open_add_athlete_modal
    @browser.button(:text, 'Invite Athletes').click
    TED.modal.button(:text, 'Manually Add Athlete').click
    TED.modal.button(:text, 'Add Athlete').click; sleep 0.5
  end

  def send_invite_email
    # find and click the not sent button for the newly added athlete
    # make sure Edit Athlete modal shows up before proceeding
    row = TED.get_row_by_name(@athlete_name)
    row.elements(:tag_name, 'td')[4].element(:class, 'btn-primary').click; sleep 1
    assert TED.modal.visible?, 'Edit Athlete modal not found'

    TED.modal.button(:text, 'Save & Invite').click
    UIActions.wait_for_modal

    # refresh the page and go back to athlete tab
    # make sure athlete status is now pending after email sent
    status = TED.get_athlete_status(@athlete_name)
    assert_equal status, 'Pending', "Expected status #{status} to be Pending"
  end

  def delete_athlete
    TED.delete_athlete(@athlete_name)
    refute (@browser.html.include? @athlete_name), "Found deleted athlete #{@athlete_name}"
  end

  def create_athlete_account
    # add a new freshman recruit, get back his email address and username
    _post, post_body = RecruitAPI.new.ppost
    @athlete_email = post_body[:recruit][:athlete_email]
    @first_name = post_body[:recruit][:athlete_first_name]
    @last_name = post_body[:recruit][:athlete_last_name]
    @athlete_name = "#{@first_name} #{@last_name}"
  end

  def college_coach_emails_hidden
    @browser.goto(Default.env_config['ted']['base_url'] + '/colleges/15568')
    UIActions.wait_for_spinner

    refute @browser.element(:text, 'Staff Directory').present?, 'College Coaches visible to unverified coach.'
  end

  def add_other_staff_blocked
    refute @browser.element(:text, 'Add Staff').present?, 'Add Staff button visible to unverified coach.'
  end

  def verify_other_staff_blocked
    @browser.button(:text, 'Unverified').click
    assert TED.modal.element(:class, 'modal-body').text.include?('You do not have permission to verify coaches.'),
      'Modal does not block unverified coaches from adding new staff.'
  end

  def test_unverified_coach_add_new_athlete
    UIActions.ted_login(@coach_email, @coach_password)
    TED.go_to_athlete_tab
    set_athlete_attributes
    add_ted_athlete_through_ui
    send_invite_email
    delete_athlete
  end

  def test_unverified_coach_add_existing_athlete
    create_athlete_account
    UIActions.ted_login(@coach_email, @coach_password)
    TED.go_to_athlete_tab
    add_ted_athlete_through_ui
    send_invite_email
    delete_athlete
  end

  def test_unverified_coach_blocked_features
    UIActions.ted_login(@coach_email, @coach_password)
    college_coach_emails_hidden

    TED.go_to_staff_tab
    add_other_staff_blocked
    verify_other_staff_blocked
  end
end
