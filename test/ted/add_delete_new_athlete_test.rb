# encoding: utf-8
require_relative '../test_helper'

# UI TED Regression
# TS-229: Add/Invite New Athlete
# TS-259: Remove Athlete From Organization
class TEDAddDeleteNewAthleteTest < Minitest::Test
  def setup    
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@browser)
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Welcome'

    @email = MakeRandom.email
    @first_name = MakeRandom.name
    @last_name = MakeRandom.name
    @athlete_name = "#{@first_name} #{@last_name}"
  end

  def teardown
    @browser.close
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
    modal.button(:text, 'Add Athlete').click; sleep 1

    # make sure athlete name shows up after added
    assert (@browser.html.include? @athlete_name), 'Cannot find newly added Athlete'
  end

  def send_invite_email
    # find and click the not sent button for the newly added athlete
    # make sure Edit Athlete modal shows up before proceeding
    row = table.elements(:tag_name, 'tr').last
    row.elements(:tag_name, 'td')[4].element(:class, 'btn-primary').click
    assert @browser.element(:class, 'modal-content').visible?

    modal = @browser.element(:class, 'modal-content')
    modal.button(:text, 'Save & Invite').click; sleep 1

    # refresh the page and go back to athlete tab
    # make sure athlete status is now pending after email sent
    TED.go_to_athlete_tab
    status = row.elements(:tag_name, 'td')[4].text
    assert_equal status, 'Pending', "Expected status #{status} to be Pending"

    UIActions.clear_cookies
  end

  def check_welcome_email
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

  def check_team_directory
    @browser.goto 'https://team-staging.ncsasports.org/team_directory'
    msg = "Found deleted athlete #{@athlete_name} in team directory"
    refute (@browser.html.include? @athlete_name), msg
  end

  def test_add_delete_new_athlete
    add_athlete
    send_invite_email
    check_welcome_email
    check_athlete_profile
    check_athlete_accepted_status
    delete_athlete
    check_team_directory
  end
end
