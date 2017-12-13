# encoding: utf-8
require_relative '../test_helper'
require 'securerandom'

# TS-229: TED Regression
# UI Test:  Add/Invite New Athlete
class TEDAddNewAthleteTest < Minitest::Test
  def setup    
    @ui = LocalUI.new(true)
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@ui)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Welcome'
    @gmail.subject = 'Welcome to NCSA Team Edition'

    @email = "ncsa.automation+#{SecureRandom.hex(2)}@gmail.com"
    @first_name = MakeRandom.name
    @last_name = MakeRandom.name
  end

  def teardown
    @browser.close
  end

  def go_to_athlete_tab
    @browser.find_element(:css, 'a.icon.administration').click
    @browser.find_element(:id, 'react-tabs-2').click; sleep 3
  end

  def get_rows
    tab = @browser.find_element(:class, 'ReactTabs__TabPanel--selected')
    table = tab.find_element(:class, 'table')
    
    table.find_element(:tag_name, 'tbody').find_elements(:tag_name, 'tr')
  end

  def add_athlete
    # go to administration -> athlete
    UIActions.coach_login; sleep 5
    go_to_athlete_tab

    # find add athlete button and click
    @browser.find_elements(:tag_name, 'button').each do |e|
      e.text == 'Add Athlete' ? (e.click; sleep 1; break) : next
    end

    # fill out athlete form
    modal = @browser.find_element(:class, 'modal-content')
    modal.find_elements(:tag_name, 'input')[0].send_keys @first_name              # first name
    modal.find_elements(:tag_name, 'input')[1].send_keys @last_name               # last name
    modal.find_elements(:tag_name, 'input')[2].send_keys MakeRandom.grad_yr       # graduation year
    modal.find_elements(:tag_name, 'input')[3].send_keys MakeRandom.number(5)     # zipcode
    modal.find_elements(:tag_name, 'input')[4].send_keys @email                   # email
    modal.find_elements(:tag_name, 'input')[5].send_keys MakeRandom.number(10)    # phone
    
    # find add athlete button and click
    # not sure why but without recognizing the text, the button won't click
    @browser.find_elements(:tag_name, 'button').each do |e|
      e.text == 'Add Athlete' ? (e.click; sleep 1) : next
    end
  end

  def send_invite_email
    row = get_rows.last
    athlete_name = row.find_elements(:tag_name, 'td')[0].text
    # make sure athlete name shows up after added
    assert (athlete_name.eql? "#{@first_name} #{@last_name}"), 'Cannot find newly added Athlete'

    # find and click the not sent button for the newly added athlete
    row.find_elements(:tag_name, 'td')[4].find_element(:class, 'btn-primary').click
    # make sure Edit Athlete modal shows up before proceeding
    assert @browser.find_element(:class, 'modal-content').displayed?

    @browser.find_elements(:tag_name, 'button').each do |e|
      e.text == 'Save & Invite' ? (e.click; sleep 5; break) : next
    end

    # make sure athlete status is now pending after email sent
    @browser.find_element(:class, 'social').location_once_scrolled_into_view; sleep 1
    status = row.find_elements(:tag_name, 'td')[4].text
    assert_equal status, 'Pending', "Expected status #{status} to be Pending"

    @browser.manage.delete_all_cookies
  end

  def check_email
    emails = @gmail.get_emails_by_subject
    refute_empty emails, 'No welcome email found after inviting athlete'
    @gmail.delete(emails)
  end

  def check_athlete_profile
    #UIActions.user_login(@email)
    POSSetup.set_password(@email)

    @browser.find_element(:class, 'fa-angle-down').click
    navbar = @browser.find_element(:id, 'secondary-nav-menu')
    navbar.find_element(:link_text, 'Membership Info').click

    container = @browser.find_element(:class, 'purchase-summary-js')
    title = container.find_element(:class, 'title-js').text

    expect_str = 'CLUB ATHLETE MEMBERSHIP FEATURES'
    assert_equal expect_str, title, "#{title} not match expected #{expect_str}"
  end

  def check_athlete_accepted_status
    UIActions.coach_login; sleep 5
    go_to_athlete_tab; sleep 1
    get_rows.each do |row|
      athlete_name = row.find_elements(:tag_name, 'td')[0].text
      if athlete_name == "#{@first_name} #{@last_name}"
        status = row.find_elements(:tag_name, 'td')[4].text
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
