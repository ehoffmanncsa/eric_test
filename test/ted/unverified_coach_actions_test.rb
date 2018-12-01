# encoding: utf-8
require_relative '../test_helper'

# TED-1429: Test Unverified Coach Actions on the site

class UnverifiedCoachActionsTest < Common
  def setup
    super

    TED.setup(@browser)
    TEDOrgApi.setup
    TEDAthleteApi.setup

    @coach_email = Default.env_config['ted']['unverified_username']
    @coach_password = Default.env_config['ted']['unverified_password']

    @org_id = TEDOrgApi.get_org_id_by_name('Frozen High')
    TEDAthleteApi.org_id = @org_id
  end

  def teardown
    super
  end

  def open_add_athlete_modal
    @browser.button(:text, 'Invite Athletes').click
    TED.modal.button(:text, 'Manually Add Athlete').click
    TED.modal.button(:text, 'Add Athlete').click; sleep 0.5

    Watir::Wait.until { TED.modal.visible? }
  end

  def fill_in_textfields
    form = TED.modal

    form.text_field(:id, 'firstName').set @first_name ||= MakeRandom.first_name
    form.text_field(:id, 'lastName').set @last_name ||= MakeRandom.last_name
    form.text_field(:id, 'graduationYear').set @grad_yr ||= MakeRandom.grad_yr
    form.text_field(:id, 'zipCode').set @zip_code ||= MakeRandom.zip_code
    form.text_field(:id, 'email').set @athlete_email ||= MakeRandom.email
    form.text_field(:id, 'phone').set @phone_number ||= MakeRandom.phone_number
  end

  def select_team
    teams_list = TED.modal.select_list(:id, 'teamId')
    teams_list.options.to_a.sample.click
  end

  def add_ted_athlete_through_ui
    open_add_athlete_modal

    fill_in_textfields
    select_team

    TED.modal.button(:text, 'Add Athlete').click
    UIActions.wait_for_modal; sleep 3

    @athlete_name = "#{@first_name} #{@last_name}"
    @athlete_id = TEDAthleteApi.get_athlete_id_by_email(@athlete_email)

    # make sure athlete name shows up after added
    assert (@browser.element(:text, @athlete_name).present?),
      "Cannot find newly added Athlete #{@athlete_name}"
  end

  def delete_athlete
    TED.delete_athlete(@athlete_name)
    refute (@browser.html.include? @athlete_name), "Found deleted athlete #{@athlete_name}"
  end

  def create_new_client
    # add a new freshman recruit, get back his email address and username
    _post, post_body = RecruitAPI.new.ppost

    @first_name = post_body[:recruit][:athlete_first_name]
    @last_name = post_body[:recruit][:athlete_last_name]
    @athlete_email = post_body[:recruit][:athlete_email]
    @zip_code = post_body[:recruit][:zip]
    @phone_number = post_body[:recruit]['athlete_phone']
    @grad_yr = post_body[:recruit][:graduationYear]
  end

  def college_coach_emails_hidden
    @browser.goto(Default.env_config['ted']['base_url'] + 'colleges/15568')
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

  def accept_invitation
    UIActions.user_login(@athlete_email); sleep 2
    Watir::Wait.until { @browser.element(:class, 'mfp-content').visible? }
    popup = @browser.element(:class, 'mfp-content')
    popup.element(:class, 'button--secondary').click
  end

  def check_athlete_accepted
    @browser.goto(Default.env_config['ted']['base_url'])
    status = TED.get_athlete_status(@athlete_name)
    assert_equal 'Accepted', status, "Expected status #{status} to be Accepted"
  end

  def find_UCLA
    @browser.button(:text, 'Recommend Colleges').click
    search_bar = @browser.element(:type, 'search')
    search_bar.send_keys 'UCLA'
    search_bar.send_keys :enter

    UIActions.wait_for_spinner
  end

  def check_recommend_college
    @browser.goto(Default.env_config['ted']['base_url'] + "athletes/#{@athlete_id}")

    find_UCLA

    @browser.element(:class, 'fa-thumbs-o-up').click; sleep 1

    assert @browser.element(:text, 'Remove Recommendation').present?,
      'Could not recommend college to athlete'

    TED.modal.element(:class, 'fa-times').click
  end

  def check_unrecommend_college
    find_UCLA

    @browser.element(:class, 'fa-thumbs-up').click; sleep 1

    assert @browser.element(:text, 'Recommend College').present?,
      'Could not unrecommend college to athlete'

    TED.modal.element(:class, 'fa-times').click
  end

  def test_unverified_coach_add_new_athlete
    UIActions.ted_login(@coach_email, @coach_password)

    TED.go_to_athlete_tab
    add_ted_athlete_through_ui

    TEDAthleteApi.send_invite_email(@athlete_id)
    TED.check_welcome_email
    accept_invitation
    check_athlete_accepted

    check_recommend_college
    check_unrecommend_college

    TEDAthleteApi.delete_athlete(@athlete_id)
  end

  def test_unverified_coach_add_existing_athlete
    create_new_client

    UIActions.ted_login(@coach_email, @coach_password)

    TED.go_to_athlete_tab
    add_ted_athlete_through_ui

    TEDAthleteApi.send_invite_email(@athlete_id)
    TED.check_welcome_email

    TEDAthleteApi.delete_athlete(@athlete_id)
  end

  def test_unverified_coach_blocked_features
    UIActions.ted_login(@coach_email, @coach_password)
    college_coach_emails_hidden

    TED.go_to_staff_tab
    add_other_staff_blocked
    verify_other_staff_blocked
  end
end
