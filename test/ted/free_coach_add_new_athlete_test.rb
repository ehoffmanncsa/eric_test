# encoding: utf-8
require_relative '../test_helper'

# UI TED Regression
# TS-260: Add/Invite New Athlete as Free Coach
class FreeCoachAddNewAthleteTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@browser)
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Welcome'
    @gmail.sender = 'TeamEdition@ncsasports.org'

    @athlete_email = MakeRandom.email
    @first_name = MakeRandom.name
    @last_name = MakeRandom.name
    @athlete_name = "#{@first_name} #{@last_name}"

    creds = YAML.load_file('config/.creds.yml')
    @coach_username = creds['ted_coach']['free_username']
    @coach_password = creds['ted_coach']['password']
  end

  def teardown
    @browser.close
  end

  def add_athlete
    UIActions.ted_coach_login(@coach_username, @coach_password)
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
    modal.elements(:tag_name, 'input')[4].send_keys @athlete_email           # email
    modal.elements(:tag_name, 'input')[5].send_keys MakeRandom.number(10)    # phone
    modal.button(:text, 'Add Athlete').click; sleep 1

     # make sure athlete name shows up after added
    assert (@browser.html.include? @athlete_name), 'Cannot find newly added Athlete'
  end

  def table
    @browser.table(:class, 'table--administration')
  end

  def send_invite_email
    # find and click the not sent button for the newly added athlete
    # make sure Edit Athlete modal shows up before proceeding
    row = table.elements(:tag_name, 'tr').last
    row.elements(:tag_name, 'td')[4].element(:class, 'btn-primary').click
    assert @browser.element(:class, 'modal-content').visible?

    modal = @browser.element(:class, 'modal-content')
    modal.button(:text, 'Save & Invite').click; sleep 5

    # make sure athlete status is now pending after email sent
    status = row.elements(:tag_name, 'td')[4].text
    assert_equal status, 'Pending', "Expected status #{status} to be Pending"

    UIActions.clear_cookies
  end

  def check_email
    emails = @gmail.get_emails_by_subject
    refute_empty emails, 'No welcome email found after inviting athlete'
    @gmail.delete(emails)
  end

  def check_athlete_profile
    POSSetup.set_password(@athlete_email)
    @browser.element(:class, 'fa-angle-down').click
    navbar = @browser.element(:id, 'secondary-nav-menu')
    refute (navbar.html.include? 'Membership Info'), 'Found membership option in menu'
  end

  def check_athlete_accepted_status
    UIActions.ted_coach_login(@coach_username, @coach_password)
    TED.go_to_athlete_tab
    row = TED.get_row_by_name(table, @athlete_name)
    status = row.elements(:tag_name, 'td')[4].text
    assert_equal 'Accepted', status, "Expected status #{status} to be Accepted"
  end

  def delete_athlete
    row = TED.get_row_by_name(table, @athlete_name)
    cog = row.elements(:tag_name, 'td').last.element(:class, 'fa-cog')
    cog.click; sleep 1
    modal = @browser.div(:class, 'modal-content')
    modal.button(:text, 'Delete').click
    small_modal = modal.div(:class, 'modal-content')
    small_modal.button(:text, 'Delete').click; sleep 1

    refute (@browser.html.include? @athlete_name), "Found deleted athlete #{@athlete_name}"
  end

  def check_team_directory
    @browser.goto 'https://team-staging.ncsasports.org/team_directory'
    msg = "Found deleted athlete #{@athlete_name} in team directory"
    refute (@browser.html.include? @athlete_name), msg
  end

  def test_add_delete_new_athlete_as_free_coach
    add_athlete
    send_invite_email
    check_email
    check_athlete_profile
    check_athlete_accepted_status
    delete_athlete
    check_team_directory
  end
end
