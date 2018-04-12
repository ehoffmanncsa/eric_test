# encoding: utf-8
require_relative '../test_helper'

# UI TED Regression
# TS-229: Add/Invite New Athlete
# TS-259: Remove Athlete From Organization

=begin
  This test use coach admin Tiffany of Awesome Sauce organization
  Coach admin add new athlete in UI via Administration page Athlete tab
  This athlete has yet to exist in C3PO database
  Make sure his name is found in Athlete table after added
  Click on Not Sent button of this athlete and send invitation
  In gmail account find Invitation email in TED_Welcome mailbox
  Make sure the athlete get an invite email then delete email
  Login to clientrms as the new athlete
  He should see TOS prompt and accept it before able to set new password
  After setting new password, make sure he has TED champion membership
  Athlete status in TED is now Accepted
  Delete this athlete
  Make sure his name is removed from Athlete table and Team Directory
=end

class TEDAddDeleteNewAthleteTest < Common
  def setup
    super
    POSSetup.setup(@browser)
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection

    @email = MakeRandom.email
    @first_name = MakeRandom.name
    @last_name = MakeRandom.name
    @athlete_name = "#{@first_name} #{@last_name}"
    puts "Adding athlete name: #{@athlete_name}"
  end

  def table
    @browser.table(:class, 'table--administration')
  end

  def add_athlete
    UIActions.ted_login
    TED.go_to_athlete_tab

    # find add athlete button and click
    @browser.button(:text, 'Add Athlete').click

    # fill out athlete form
    Watir::Wait.until { @browser.element(:class, 'modal-content').visible? }
    modal = @browser.element(:class, 'modal-content')
    modal.elements(:tag_name, 'input')[0].send_keys @first_name              # first name
    modal.elements(:tag_name, 'input')[1].send_keys @last_name               # last name
    modal.elements(:tag_name, 'input')[2].send_keys MakeRandom.grad_yr       # graduation year
    modal.elements(:tag_name, 'input')[3].send_keys MakeRandom.number(5)     # zipcode
    modal.elements(:tag_name, 'input')[4].send_keys @email                   # email
    modal.elements(:tag_name, 'input')[5].send_keys MakeRandom.number(10)    # phone
    modal.button(:text, 'Add Athlete').click; sleep 2

    # make sure athlete name shows up after added
    assert (@browser.element(:text, @athlete_name).present?), "Cannot find newly added Athlete #{@athlete_name}"
  end

  def send_invite_email
    # find and click the not sent button for the newly added athlete
    # make sure Edit Athlete modal shows up before proceeding
    row = table.element(:text, @athlete_name).parent
    row.elements(:tag_name, 'td')[4].element(:class, 'btn-primary').click; sleep 1
    assert @browser.element(:class, 'modal-content').visible?

    modal = @browser.element(:class, 'modal-content')
    modal.button(:text, 'Save & Invite').click
    Watir::Wait.while { modal.present? }

    # refresh the page and go back to athlete tab
    # make sure athlete status is now pending after email sent
    status = TED.get_athlete_status(table, @athlete_name)
    assert_equal status, 'Pending', "Expected status #{status} to be Pending"

    TED.sign_out
  end

  def check_accepted_email
    @gmail.mail_box = 'Inbox'
    @gmail.subject = "#{@athlete_name} has accepted your Team Edition request"
    emails = @gmail.get_unread_emails
    refute_empty emails, 'No accepted email found after athlete accepted invitation'

    @gmail.delete(emails)
  end

  def check_welcome_email
    @gmail.mail_box = 'TED_Welcome'
    @gmail.subject = 'Welcome to NCSA Team Edition'
    emails = @gmail.get_unread_emails
    refute_empty emails, 'No welcome email found after inviting athlete'

    @gmail.delete(emails)
  end

  def check_athlete_profile
    POSSetup.set_password(@email)
    @browser.element(:class, 'fa-angle-down').click
    navbar = @browser.element(:id, 'secondary-nav-menu')
    navbar.link(:text, 'Membership Info').click
    container = @browser.element(:class, 'purchase-summary-js')
    title = container.element(:class, 'title-js').text
    expect_str = 'CLUB ATHLETE MEMBERSHIP FEATURES'
    assert_equal expect_str, title, "#{title} not match expected #{expect_str}"
  end

  def check_athlete_accepted_status
    UIActions.ted_login
    status = TED.get_athlete_status(table, @athlete_name)
    assert_equal 'Accepted', status, "Expected status #{status} to be Accepted"
  end

  def delete_athlete
    TED.delete_athlete(table, @athlete_name)
    refute (@browser.html.include? @athlete_name), "Found deleted athlete #{@athlete_name}"
  end

  def test_add_delete_new_athlete
    add_athlete
    send_invite_email
    check_welcome_email
    check_athlete_profile
    check_athlete_accepted_status
    check_accepted_email
    delete_athlete
  end
end
