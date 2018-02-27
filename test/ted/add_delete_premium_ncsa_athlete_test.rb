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
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Welcome'
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
    @athlete_name = "#{@first_name} #{@last_name}"
  end

  def modal
    @browser.element(:class, 'modal-content')
  end

  def add_athlete
    UIActions.ted_login
    TED.go_to_athlete_tab

    # find add athlete button and click
    @browser.button(:text, 'Add Athlete').click

    # fill out athlete form
    modal.elements(:tag_name, 'input')[0].send_keys @first_name              # first name
    modal.elements(:tag_name, 'input')[1].send_keys @last_name               # last name
    modal.elements(:tag_name, 'input')[2].send_keys @grad_yr                 # graduation year
    modal.elements(:tag_name, 'input')[3].send_keys MakeRandom.number(5)     # zipcode
    modal.elements(:tag_name, 'input')[4].send_keys @email                   # email
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
    assert modal.visible?

    modal.button(:text, 'Save & Invite').click; sleep 5

    # make sure athlete status is now pending after email sent
    status = row.elements(:tag_name, 'td')[4].text
    assert_equal status, 'Pending', "Expected status #{status} to be Pending"

    TED.sign_out
  end

  def check_welcome_email
    @gmail.subject = 'Welcome to NCSA Team Edition'
    emails = @gmail.get_unread_emails
    refute_empty emails, 'No welcome email found after inviting athlete'

    @gmail.delete(emails)
  end

  def athlete_accept_invitation
    UIActions.user_login(@email); sleep 2
    Watir::Wait.until { @browser.element(:class, 'mfp-content').visible? }
    popup = @browser.element(:class, 'mfp-content')
    popup.element(:class, 'button--secondary').click

    athlete_sign_out
  end

  def upgrade_athlete
    TED.impersonate_org('Awesome Volleyball')
    TED.go_to_athlete_tab
    row = TED.get_row_by_name(table, @athlete_name)
    cog = row.elements(:tag_name, 'td').last.element(:class, 'fa-cog')
    cog.click; sleep 1
    modal.button(:text, 'Upgrade').click
    Watir::Wait.until { modal.div(:class, 'alert-success').present? }

    # close modal and signout
    modal.element(:class, 'fa-times').click
    TED.sign_out
  end

  def check_athlete_premium_profile
    # Giving staging grace period before checking premium status
    UIActions.user_login(@email); sleep 2
    @browser.element(:class, 'fa-angle-down').click
    navbar = @browser.element(:id, 'secondary-nav-menu')
    navbar.link(:text, 'Membership Info').click
    expect_str = 'MVP/TEAM EDITION MEMBERSHIP FEATURES'
    begin
      Timeout::timeout(30) {
        loop do
          container = @browser.element(:class, 'purchase-summary-js')
          @title = container.element(:class, 'title-js').text
          break unless @title.include? 'CHAMPION'
          @browser.refresh
        end
      }
    rescue; end

    assert_equal expect_str, @title, "#{@title} not match expected #{expect_str}"

    athlete_sign_out
  end

  def athlete_sign_out
    @browser.element(:class, 'fa-angle-down').click
    navbar = @browser.element(:id, 'secondary-nav-menu')
    navbar.link(:text, 'Logout').click
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

  def check_athlete_free_profile
    # as athlete is now deleted from TED, he becomes free
    UIActions.clear_cookies
    UIActions.user_login(@email)

    # If an athlete is free, there shouldn't be Membership Info in menu
    @browser.element(:class, 'fa-angle-down').click
    navbar = @browser.element(:id, 'secondary-nav-menu')
    refute (navbar.html.include? 'Membership Info'), 'Found membership option in menu'
  end

  def test_add_delete_premium_ncsa_athlete
    create_athlete
    POSSetup.buy_package(@email, 'champion')
    add_athlete
    send_invite_email
    check_welcome_email
    athlete_accept_invitation

    upgrade_athlete
    check_athlete_premium_profile
    check_athlete_accepted_status
    delete_athlete
    check_team_directory
    check_athlete_free_profile
  end
end
