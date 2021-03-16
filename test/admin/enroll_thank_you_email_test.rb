# frozen_string_literal: true

require_relative '../test_helper'

# TS-56: MS Regression
# UI Test: Enroll as a Elite User - Junior
class EnrollThankYouEmailTest < Common
  def setup
    super

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'Enroll_Thank_You'
    @gmail.sender = 'recruitinghelp@ncsasports.org'

    enroll_yr = 'junior'
    @package = 'elite'
    @clientrms = Default.env_config['clientrms']

    _post, post_body = RecruitAPI.new(enroll_yr).ppost
    recruit_first = post_body[:recruit][:athlete_first_name]
    recruit_last = post_body[:recruit][:athlete_last_name]
    recruit_email = post_body[:recruit][:athlete_email]
    @athlete_name = "#{recruit_first} #{recruit_last}"

    UIActions.user_login(recruit_email)
    MSTestTemplate.setup(@browser, recruit_email, @package)
  end

  def teardown
    super
  end

  def delete_thank_you_mailbox_emails
    # need to clear out emails from other membership scripts
    @gmail.delete(@gmail.remove_unread_emails)
  end

  def get_athlete_name_from_email
    # use keyword 'For' to get athlete name
    emails = @gmail.get_unread_emails
    msg = @gmail.parse_body(emails.last, 'For')
    @recruit_name_gmail = msg.split(' ')[1..2].join(' ')
  end

  def check_recruit_name_gmail
    # compares the recruit name to the name in the gmail
    assert_equal @athlete_name, @recruit_name_gmail, 'Athlete name in gmail is not correct'
  end

  def check_membership_details
    emails = @gmail.get_unread_emails
    msg = @gmail.parse_body(emails.last).gsub(/[\n=]/, '')

    failure = []
    failure << 'Membership not found' unless msg.include? 'Elite'
    failure << 'Payment info not found' unless msg.include? '6 Payments over 6 Months'
    assert_empty failure
  end

  def test_enroll_elite_junior
    delete_thank_you_mailbox_emails
    MSTestTemplate.get_enrolled
    get_athlete_name_from_email
    check_recruit_name_gmail
    check_membership_details
  end
end
