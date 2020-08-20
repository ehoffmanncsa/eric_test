# frozen_string_literal: true

require_relative '../test_helper'

# Ts-601 MS Regression
# UI Test: Create user, schedule a calendly meeting and then confirm meeting displays
# on the dashboard. had to log out and log on to see appointment on dashboard.
class ScheduleAssessmentTest < Common
  def setup
    super
    MSSetup.setup(@browser)

    enroll_yr = 'junior'
    @clientrms = Default.env_config['clientrms']

    _post, post_body = RecruitAPI.new(enroll_yr).ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    @recruit_name = post_body[:recruit][:athlete_first_name]

    # email = 'test2e33@yopmail.com'
    UIActions.user_login(@recruit_email)
    MSSetup.set_password

    @gmail = GmailCalls.new
    @gmail.get_connection
  end

  def teardown
    super
  end

  def close_supercharge
    supercharge_button = @browser.element(class: 'CloseIcon-lmXKkg')
    supercharge_button.click if supercharge_button.exists?
    sleep 1
    yes_exit_button = @browser.element(text: 'Yes, Exit for Now')
    yes_exit_button.click if yes_exit_button.exists?
    sleep 1
    supercharge_button = @browser.element(class: 'CloseIcon-lmXKkg')
    supercharge_button.click if supercharge_button.exists?
    sleep 2
  end

  def select_schedule
    @browser.element('data-test-id': 'recruiting-assessment-button').click
    sleep 2
  end

  def select_parent
    @browser.element(text: "I'm a Parent").click
    sleep 1
  end

  def select_day
    calendar_day = @browser.iframe(class: 'ncsa-iframe')
    calendar_day.iframe.elements(class: 'U5hxE___day-Button__bookable').first.click
    sleep 1
  end

  def select_time
    calendar_time = @browser.iframe(class: 'ncsa-iframe')
    calendar_time.iframe.elements('data-container': 'time-button').first.click
    sleep 2
    calendar_time.iframe.element('data-container': 'confirm-button').click
    sleep 1
  end

  def enter_name
    name = @browser.iframe(class: 'ncsa-iframe')
    name.iframe.element(type: 'text').send_keys @recruit_name
    sleep 1
  end

  def enter_email
    email = @browser.iframe(class: 'ncsa-iframe')
    email.iframe.element(type: 'email').to_subtype.clear
    email.iframe.element(type: 'email').send_keys @recruit_email
    sleep 1
  end

  def enter_phone
    phone = @browser.iframe(class: 'ncsa-iframe')
    phone.iframe.element(type: 'tel').to_subtype.clear
    phone.iframe.element(type: 'tel').send_keys '3124567890'
    sleep 1
  end

  def select_device
    device = @browser.iframe(class: 'ncsa-iframe')
    device.iframe.elements(class: '_2ORJu___styles-Body__cls1').first.click
    sleep 1
  end

  def select_gpa
    gpa = @browser.iframe(class: 'ncsa-iframe')
    gpa.iframe.elements(class: '_22WAz___styles-Body__cls1')[4].click
    sleep 1
  end

  def select_experience
    experience = @browser.iframe(class: 'ncsa-iframe')
    experience.iframe.elements(class: '_2ORJu___styles-Body__cls1')[7].click
    sleep 1
  end

  def select_help
    help = @browser.iframe(class: 'ncsa-iframe')
    help.iframe.elements(class: '_2ORJu___styles-Body__cls1')[13].click
    sleep 1
  end

  def been_recruited
    recruit = @browser.iframe(class: 'ncsa-iframe')
    recruit.iframe.elements(class: '_22WAz___styles-Body__cls1')[8].click
    sleep 1
  end

  def schedule_event
    schedule = @browser.iframe(class: 'ncsa-iframe')
    schedule.iframe.elements(class: 'MOKW6___Button__cls1').last.click
    sleep 8
  end

  def schedule_close
    close = @browser.element(class: 'ncsa-modal-content')
    close.element(class: 'ncsa-close').click
    sleep 5
  end

  def clientrms_sign_out
    @browser.element(class: 'fa-angle-down').click
    navbar = @browser.element(id: 'secondary-nav-menu')
    navbar.link(text: 'Logout').click
  end

  def check_dashboard
    failure = []
    begin
      five_minutes = 300 # seconds
      Timeout.timeout(five_minutes) do
        loop do
          html = @browser.html
          break if html.include? 'Upcoming Recruiting Assessment'

          @browser.refresh
        end
      end
    rescue StandardError => e
      failure << 'Appointment does not display after 2 minutes wait'
    end
    assert_empty failure
  end

  def check_meeting_prep_drill
    failure = []
    begin
      five_minutes = 300 # seconds
      Timeout.timeout(five_minutes) do
        loop do
          html = @browser.html
          break if html.include? 'Meeting Prep'

          @browser.refresh
        end
      end
    rescue StandardError => e
      failure << 'Meeting Prep Drill does not display after 2 minutes wait'
    end
    assert_empty failure
  end

  def check_accepted_email
    @gmail.mail_box = 'Calendly'
    emails = @gmail.get_unread_emails

    @gmail.delete(emails) unless emails.empty?
  end

  def test_schedule_assessment
    close_supercharge
    select_schedule
    select_parent
    select_day
    select_time
    enter_name
    enter_email
    enter_phone
    select_device
    select_gpa
    select_experience
    select_help
    been_recruited
    schedule_event
    schedule_close
    clientrms_sign_out
    sleep 5
    check_accepted_email
    UIActions.user_login(@recruit_email, 'ncsa1333')
    check_dashboard
    UIActions.goto_ncsa_university
    check_meeting_prep_drill
  end
end
