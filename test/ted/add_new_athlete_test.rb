# encoding: utf-8
require_relative '../test_helper'

# TS-229: TED Regression
# UI Test:  Add/Invite New Athlete
class TEDAddNewAthleteTest < Minitest::Test
  def setup    
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Welcome'
    @gmail.subject = 'Welcome to NCSA Team Edition'

    @email = MakeRandom.email
    @first_name = MakeRandom.name
    @last_name = MakeRandom.name
  end

  def teardown
    @browser.close
  end

  def go_to_athlete_tab
    # go to administration -> athlete
    Watir::Wait.until { @browser.element(:class, 'sidebar').visible? }
    @browser.link(:text, 'Administration').click
    Watir::Wait.until { @browser.element(:id, 'react-tabs-1').visible? }
    @browser.element(:id, 'react-tabs-2').click
    Watir::Wait.until { @browser.element(:id, 'react-tabs-3').visible? }
  end

  def get_rows
    tab = @browser.element(:class, 'ReactTabs__TabPanel--selected')
    table = tab.element(:class, 'table')
    
    table.element(:tag_name, 'tbody').elements(:tag_name, 'tr')
  end

  def add_athlete
    UIActions.ted_coach_login
    go_to_athlete_tab

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
    modal.button(:text, 'Add Athlete').click
  end

  def send_invite_email
    # make sure athlete name shows up after added
    row = get_rows.last
    athlete_name = row.elements(:tag_name, 'td')[0].text
    assert (athlete_name.eql? "#{@first_name} #{@last_name}"), 'Cannot find newly added Athlete'

    # find and click the not sent button for the newly added athlete
    # make sure Edit Athlete modal shows up before proceeding
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
    UIActions.ted_coach_login
    go_to_athlete_tab; sleep 1
    get_rows.each do |row|
      athlete_name = row.elements(:tag_name, 'td')[0].text
      if athlete_name == "#{@first_name} #{@last_name}"
        status = row.elements(:tag_name, 'td')[4].text
        assert_equal 'Accepted', status, "Expected status #{status} to be Accepted"
        break
      else
        next
      end
    end
  end

  def test_add_new_athlete
    add_athlete
    send_invite_email
    check_email
    check_athlete_profile
    check_athlete_accepted_status
  end
end
