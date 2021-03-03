# frozen_string_literal: true

require_relative '../test_helper'

# Ts-601 MS Regression
# UI Test: Create user, schedule a calendly meeting and then confirm meeting displays
# on the dashboard.
class ScheduleAssessmentTest < Common
  def setup
    super
    Calendly.setup(@browser)
  end

  def teardown
    super
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
          sleep 3
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
          sleep 3
        end
      end
    rescue StandardError => e
      failure << 'Meeting Prep Drill does not display after 2 minutes wait'
    end
    assert_empty failure
  end

  def check_accepted_email
    @gmail = GmailCalls.new
    @gmail.get_connection

    @gmail.mail_box = 'Calendly'
    emails = @gmail.get_unread_emails

    @gmail.delete(emails) unless emails.empty?
  end

  def test_schedule_assessment
    UIActions.close_supercharge
    Calendly.select_schedule
    Calendly.select_parent
    Calendly.fill_out_calendly_form
    Calendly.schedule_event
    Calendly.schedule_close
    sleep 5
    check_accepted_email
    sleep 5
    check_dashboard
    UIActions.goto_ncsa_university
    check_meeting_prep_drill
  end
end
