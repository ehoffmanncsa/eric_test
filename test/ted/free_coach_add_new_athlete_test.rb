# encoding: utf-8
require_relative '../test_helper'

# UI TED Regression
# TS-260: Add/Invite New Athlete as Free Coach

=begin
  This test use coach admin Noel Ronnie of organization id 50 (free org)
  Coach admin add new athlete in UI via Administration page Athlete tab
  This athlete has yet to exist in C3PO database
  Make sure his name is found in Athlete table after added
  Click on Not Sent button of this athlete and send invitation
  In gmail account find Invitation email in TED_Welcome mailbox
  Make sure the athlete get an invite email then delete email
  Login to clientrms as the new athlete
  He should see TOS prompt and accept it before able to set new password
  After setting new password, make sure he remains a free user
  Athlete status in TED is now Accepted
  Delete this athlete
  Make sure his name is removed from Athlete table and Team Directory
=end

class FreeCoachAddNewAthleteTest < Common
  def setup
    super
    POSSetup.setup(@browser)
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Welcome'
    @gmail.sender = 'TeamEdition@ncsasports.org'

    creds = YAML.load_file('config/.creds.yml')
    @coach_username = creds['ted_coach']['free_username']
    @coach_password = creds['ted_coach']['free_password']
  end

  def add_athlete
    TEDAthleteApi.setup
    TEDAthleteApi.coach_api = TEDApi.new('free_coach')
    TEDAthleteApi.org_id = '50' # use free org "Test Free Org Sprint 20"

    new_athlete = TEDAthleteApi.add_athlete(nil, true)
    first_name = new_athlete['attributes']['profile']['first-name']
    last_name = new_athlete['attributes']['profile']['last-name']
    @athlete_name = "#{first_name} #{last_name}"
    @athlete_email = new_athlete['attributes']['profile']['email']

    pp "Added new athlete: #{@athlete_name}"
  end

  def table
    @browser.table(:class, 'table--administration')
  end

  def send_invite_email
    UIActions.ted_login(@coach_username, @coach_password)
    TED.go_to_athlete_tab

    # find and click the not sent button for the newly added athlete
    # make sure Edit Athlete modal shows up before proceeding
    row = table.element(:text, @athlete_name).parent
    row.elements(:tag_name, 'td')[4].element(:class, 'btn-primary').click
    assert TED.modal.visible?

    TED.modal.button(:text, 'Save & Invite').click; sleep 5

    # make sure athlete status is now pending after email sent
    status = row.elements(:tag_name, 'td')[4].text
    assert_equal status, 'Pending', "Expected status #{status} to be Pending"

    UIActions.clear_cookies
  end

  def check_welcome_email
    emails = @gmail.get_unread_emails
    refute_empty emails, 'No welcome email found after inviting athlete'

    @gmail.delete(emails)
  end

  def check_athlete_free_profile
    POSSetup.set_password(@athlete_email)
    @browser.element(:class, 'fa-angle-down').click
    navbar = @browser.element(:id, 'secondary-nav-menu')
    refute (navbar.html.include? 'Membership Info'), 'Found membership option in menu'
  end

  def check_athlete_accepted_status
    UIActions.ted_login(@coach_username, @coach_password)
    TED.go_to_athlete_tab
    row = TED.get_row_by_name(@athlete_name)
    status = row.elements(:tag_name, 'td')[4].text
    assert_equal 'Accepted', status, "Expected status #{status} to be Accepted"
  end

  def delete_athlete
    row = TED.get_row_by_name(@athlete_name)
    cog = row.elements(:tag_name, 'td').last.element(:class, 'fa-cog')
    cog.click; sleep 1

    TED.modal.button(:text, 'Delete').click
    small_modal = TED.modal.div(:class, 'modal-content')
    small_modal.button(:text, 'Delete').click; sleep 1

    refute (@browser.html.include? @athlete_name), "Found deleted athlete #{@athlete_name}"
  end

  def test_add_delete_new_athlete_as_free_coach
    add_athlete
    send_invite_email
    check_welcome_email
    check_athlete_free_profile
    check_athlete_accepted_status
    delete_athlete
  end
end
