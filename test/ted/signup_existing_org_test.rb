# encoding: utf-8
require_relative '../test_helper'

# TS-378: TED Regression
# UI Test: Add Previously Added Organization via the Sign Up Modal

=begin
  Signup for club from login page
  Use club name Awesome Sauce, verify alert for existing org shows up
  Coach admin Tiffany should receive Public Coach
    Verification Request email, verify then delete it
  A new coach should be added to Awesome Sauce org, Unverified
  Coach admin Tiffany verify new coach, get coach password
    from email then delete it
  Log in as new coach, verify there is change password modal,
    set password ncsa
  Delete this new coach afterward
=end

class SignupExistingOrgTest < Common
  def setup
    super
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection

    @org_name = 'Awesome Sauce'
    @coach_firstname = MakeRandom.name
    @coach_lastname = MakeRandom.name
    @coach_name = "#{@coach_firstname} #{@coach_lastname}"
    @coach_email = MakeRandom.email

    creds = YAML.load_file('config/.creds.yml')
    @admin_username = creds['ted_admin']['username']
    @admin_password = creds['ted_admin']['password']
  end

  def open_club_form
    @browser.goto 'https://team-staging.ncsasports.org/sign_in'
    @browser.elements(:text, 'Sign Up')[1].click
    assert TED.modal, 'Add Organization modal not found'

    # select club
    list = TED.modal.select_list(:class, 'form-control')
    list.select 'Club'

    # Make sure name is unique
    # Retry if name found
    TED.modal.text_field(:class, 'resizable-input').set @org_name; sleep 1
    assert TED.modal.div(:class, 'dropdown-menu').present?, 'No dropdown menu'

    TED.modal.div(:class, 'dropdown-menu').click
    TED.modal.button(:text, 'Select').click
  end

  def fill_out_form
    # fill out club info
    inputs = TED.modal.elements(:tag_name, 'input').to_a
    inputs[4].send_keys @coach_firstname
    inputs[5].send_keys @coach_lastname
    inputs[6].send_keys @coach_email
    inputs[7].send_keys MakeRandom.number(10)

    TED.modal.button(:text, 'Add').click; sleep 3
  end

  def verify_org_exist_alert
    assert TED.modal.div(:class, 'alert').present?, 'No alert message'

    alert = TED.modal.div(:class, 'alert')
    text = "#{@org_name} has already joined Team Edition. " \
    "An email has been sent to the primary contact on the account " \
    "with your request to join. Questions? Call NCSA at 312-999-6176."
    assert_equal text, alert.text, 'Incorrect allert message'
  end

  def get_coach_password
    @gmail.mail_box = 'TED_Welcome'
    @gmail.subject = 'Welcome to NCSA Team Edition'
    emails = @gmail.get_unread_emails
    msg = @gmail.parse_body(emails.last, 'password')
    password = msg[1].split(':').last.split()[0]
    @gmail.delete(emails)

    password
  end

  def check_verification_request_email
    @gmail.mail_box = 'Inbox'
    @gmail.subject = 'Public Coach Verification Request'
    emails = @gmail.get_unread_emails
    msg = @gmail.parse_body(emails.last)

    failure = []
    failure << 'Coach name not found' unless msg.include? @coach_name
    failure << 'Coach email not found' unless msg.include? @coach_email
    failure << 'Org name not found' unless msg.include? @org_name
    assert_empty failure

    failure.empty? ? @gmail.delete(emails) : (pp 'Check email to verify failure')
  end

  def coach_row
    @browser.element(:text, @coach_name).parent
  end

  def check_new_coach_unverified
    UIActions.ted_login
    TED.go_to_staff_tab

    @browser.element(:text, @coach_name).parent
    assert coach_row.button(:text, 'Unverified').enabled?, 'Unverified button not found'
  end

  def verify_coach
    # verify and give random text position
    coach_row.button(:text, 'Unverified').click
    TED.modal.text_field(:class, 'form-control').set MakeRandom.name
    TED.modal.button(:text, 'Verify').click
    Watir::Wait.while { TED.modal.present? }

    assert_equal coach_row.element(:class, 'text-center').text, 'Verified', 'Coach not verified'

    # logout of coach admin
    TED.sign_out
  end

  def check_new_coach_can_login
    UIActions.ted_login(@coach_email, get_coach_password)
    assert TED.modal.visible?, 'No change password modal'

    inputs = TED.modal.elements(:tag_name, 'input')
    inputs.each { |i| i.send_keys 'ncsa' }
    TED.modal.button(:text, 'Change Password').click
  end

  def delete_coach
    TEDCoachApi.setup

    coach = TEDCoachApi.get_coach_by_email(@coach_email)
    TEDCoachApi.delete_coach(coach['id'])
  end

  def test_signup_existing_org
    open_club_form
    fill_out_form

    verify_org_exist_alert
    check_verification_request_email
    check_new_coach_unverified

    verify_coach
    check_new_coach_can_login
    delete_coach
  end
end
