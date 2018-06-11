# encoding: utf-8
require_relative '../test_helper'

# TS-362: TED Regression
# UI Test: Add/Invite Previous FREE NCSA Athlete as Premium Coach

=begin
  This test use coach admin Tiffany of Awesome Sauce organization
  Since there is test cases to perform these actions in UI
  We do most actions via the api here and check for athlete profile in UI
  An existing NCSA FREE athlete is needed, create one via api
  Coach add new athlete via api
  Make sure his name is found in Athlete table
  Send invitation email via api
  In gmail account find Invitation email in TED_Welcome mailbox
  Make sure the athlete get an invite email then delete it
  Login to clientrms as the athlete
  He should see TOS prompt and accept it
  Because Awesome Sauce org has all sports, contract and team for each sport
  This athlete now has TED champion membership (CLUB ATHLETE MEMBERSHIP FEATURES)
  Athlete status in TED is now Accepted
  Delete this athlete via api
  Make sure his name is removed from Athlete table and Team Directory
=end

class PremCoachAddFreeAthlete < Common
  def setup
    super
    POSSetup.setup(@browser)
    TED.setup(@browser)
  end

  def teardown
    super
  end

  def create_athlete
    # add a new freshman recruit, get back his email address and username
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]
    @first_name = post_body[:recruit][:athlete_first_name]
    @last_name = post_body[:recruit][:athlete_last_name]
    @grad_yr = post_body[:recruit][:graduation_year]
    @phone = post_body[:recruit][:athlete_phone]
    @athlete_name = "#{@first_name} #{@last_name}"
  end

  def add_athlete
    TEDAthleteApi.setup
    TEDTeamApi.setup
    body = {
      data: {
        attributes: {
          email: @email,
          first_name: @first_name,
          graduation_year: @grad_yr,
          last_name: @last_name,
          phone: @phone,
          zip_code: MakeRandom.number(5)
        },
        relationships: {
          team: { data: { type: 'teams', id: TEDTeamApi.get_random_team_id } }
        },
        type: 'athletes'
      }
    }.to_json

    @new_athlete = TEDAthleteApi.add_athlete(body, true) # true to use coach_api
    TEDAthleteApi.athlete_id = @new_athlete['id']
  end

  def table
    @browser.table(:class, 'table--administration')
  end

  def check_athlete_added
    UIActions.ted_login
    TED.go_to_athlete_tab
    assert (@browser.element(:text, @athlete_name).present?), "Cannot find newly added Athlete #{@athlete_name}"
  end

  def send_invite_email
    TEDAthleteApi.send_invite_email
  end

  def check_pending_status
    TED.go_to_athlete_tab
    status = TED.get_athlete_status(@athlete_name)
    assert_equal status, 'Pending', "Expected status #{status} to be Pending"

    TED.sign_out
  end

  def check_athlete_membership
    # Giving staging grace period before checking premium status
    POSSetup.set_password(@email)
    @browser.element(:class, 'fa-angle-down').click
    navbar = @browser.element(:id, 'secondary-nav-menu')
    navbar.link(:text, 'Membership Info').click
    expect_str = 'CLUB ATHLETE MEMBERSHIP FEATURES'
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

    clientrms_sign_out
  end

  def clientrms_sign_out
    @browser.element(:class, 'fa-angle-down').click
    navbar = @browser.element(:id, 'secondary-nav-menu')
    navbar.link(:text, 'Logout').click
  end

  def check_athlete_accepted_status
    UIActions.ted_login
    status = TED.get_athlete_status(@athlete_name)
    assert_equal 'Accepted', status, "Expected status #{status} to be Accepted"
  end

  def delete_athlete
    TED.delete_athlete(@athlete_name)
    refute (@browser.html.include? @athlete_name), "Found deleted athlete #{@athlete_name}"
  end

  def test_add_delete_free_ncsa_athlete
    create_athlete
    add_athlete
    check_athlete_added

    send_invite_email
    check_pending_status
    TED.check_welcome_email
    check_athlete_membership

    check_athlete_accepted_status
    TED.check_accepted_email
    delete_athlete
  end
end
