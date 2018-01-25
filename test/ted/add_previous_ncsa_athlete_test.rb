# encoding: utf-8
require_relative '../test_helper'

# TS-239: TED Regression
# UI Test: Add/Invite Previous NCSA Athlete
class TEDAddPreviousAthlete < Minitest::Test
  def setup    
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Welcome'
    @gmail.subject = 'Welcome to NCSA Team Edition'
  end

  def teardown
    @browser.close
  end

  def create_athlete
    # add a new freshman recruit, get back his email address and username
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]
    @first_name = post_body[:recruit][:athlete_first_name]
    @last_name = post_body[:recruit][:athlete_last_name]
    @grad_yr = post_body[:recruit][:graduation_year]
  end

  def go_to_athlete_tab
    @browser.element(:css, 'a.icon.administration').click
    @browser.element(:id, 'react-tabs-2').click; sleep 3
  end

  def get_rows
    tab = @browser.element(:class, 'ReactTabs__TabPanel--selected')
    table = tab.element(:class, 'table')
    
    table.element(:tag_name, 'tbody').elements(:tag_name, 'tr')
  end

  def add_athlete
    # go to administration -> athlete
    UIActions.ted_coach_login; sleep 5
    go_to_athlete_tab

    # find add athlete button and click
    @browser.elements(:tag_name, 'button').each do |e|
      e.text == 'Add Athlete' ? (e.click; sleep 1; break) : next
    end

    # fill out athlete form
    modal = @browser.element(:class, 'modal-content')
    modal.elements(:tag_name, 'input')[0].send_keys @first_name        # first name
    modal.elements(:tag_name, 'input')[1].send_keys @last_name         # last name
    modal.elements(:tag_name, 'input')[2].send_keys @grad_yr           # graduation year
    modal.elements(:tag_name, 'input')[3].send_keys MakeRandom.number(5)     # zipcode
    modal.elements(:tag_name, 'input')[4].send_keys @email             # email
    modal.elements(:tag_name, 'input')[5].send_keys MakeRandom.number(10)    # phone
    
    # find add athlete button and click
    # not sure why but without recognizing the text, the button won't click
    @browser.elements(:tag_name, 'button').each do |e|
      e.text == 'Add Athlete' ? (e.click; sleep 3) : next
    end
  end

  def send_invite_email
    row = get_rows.last
    athlete_name = row.elements(:tag_name, 'td')[0].text
    # make sure athlete name shows up after added
    assert (athlete_name.eql? "#{@first_name} #{@last_name}"), 'Cannot find newly added Athlete'

    # find and click the not sent button for the newly added athlete
    row.elements(:tag_name, 'td')[4].element(:class, 'btn-primary').click
    # make sure Edit Athlete modal shows up before proceeding
    assert @browser.element(:class, 'modal-content').visible?

    @browser.elements(:tag_name, 'button').each do |e|
      e.text == 'Save & Invite' ? (e.click; sleep 5; break) : next
    end

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
    UIActions.user_login(@email)

    popup = @browser.element(:class, 'mfp-content')
    popup.element(:class, 'button--secondary').click; sleep 1

    @browser.element(:class, 'fa-angle-down').click
    navbar = @browser.element(:id, 'secondary-nav-menu')
    navbar.element(:link_text, 'Membership Info').click

    container = @browser.element(:class, 'purchase-summary-js')
    title = container.element(:class, 'title-js').text

    expect_str = 'MVP/TEAM EDITION MEMBERSHIP FEATURES'
    assert_equal expect_str, title, "#{title} not match expected #{expect_str}"
  end

  def check_athlete_accepted_status
    UIActions.ted_coach_login; sleep 5
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

  def test_add_previous_ncsa_athlete
    create_athlete
    POSSetup.buy_package(@email, 'champion')
    add_athlete
    send_invite_email
    check_email
    check_athlete_profile
    check_athlete_accepted_status
  end
end
