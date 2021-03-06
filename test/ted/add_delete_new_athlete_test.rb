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

    @email = MakeRandom.email
    @first_name = MakeRandom.first_name
    @last_name = MakeRandom.last_name
    @athlete_name = "#{@first_name} #{@last_name}"
    puts "Adding athlete name: #{@athlete_name}"
  end

  def teardown
    super
  end

  def table
    @browser.table(:class, 'table--administration')
  end

  def open_add_athlete_modal
    @browser.button(:text, 'Invite Athletes').click
    TED.modal.button(:text, 'Manually Add Athlete').click
    TED.modal.button(:text, 'Add Athlete').click; sleep 0.5
  end

  def add_athlete
    UIActions.ted_login
    TED.go_to_athlete_tab
    open_add_athlete_modal

    # fill out athlete form
    Watir::Wait.until { TED.modal.visible? }
    inputs = TED.modal.elements(:tag_name, 'input').to_a
    inputs[0].send_keys @first_name              # first name
    inputs[1].send_keys @last_name               # last name
    inputs[2].send_keys MakeRandom.grad_yr       # graduation year
    inputs[3].send_keys MakeRandom.zip_code      # zipcode
    inputs[4].send_keys @email                   # email
    inputs[5].send_keys MakeRandom.phone_number  # phone
    TED.modal.button(:text, 'Add Athlete').click
    UIActions.wait_for_modal

    # make sure athlete name shows up after added
    assert (@browser.element(:text, @athlete_name).present?), "Cannot find newly added Athlete #{@athlete_name}"
  end

  def send_invite_email
    # find and click the not sent button for the newly added athlete
    # make sure Edit Athlete modal shows up before proceeding
    row = TED.get_row_by_name(@athlete_name)
    row.elements(:tag_name, 'td')[4].element(:class, 'btn-primary').click; sleep 1
    assert TED.modal.visible?, 'Edit Athlete modal not found'

    TED.modal.button(:text, 'Save & Invite').click
    UIActions.wait_for_modal

    # refresh the page and go back to athlete tab
    # make sure athlete status is now pending after email sent
    status = TED.get_athlete_status(@athlete_name)
    assert_equal status, 'Pending', "Expected status #{status} to be Pending"

    TED.sign_out
  end

  def check_athlete_profile
    POSSetup.set_password(@email)
    @browser.element(:class, 'fa-angle-down').click

    navbar = @browser.element(:id, 'secondary-nav-menu')
    navbar.link(:text, 'Membership Info').click

    purchase_summary = @browser.element(:class, 'purchase-summary-js')
    title = purchase_summary.element(:class, 'title-js').text
    expect_str = 'CLUB ATHLETE MEMBERSHIP FEATURES'
    assert_equal expect_str, title, "#{title} not match expected #{expect_str}"
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

  def test_add_delete_new_athlete
    add_athlete
    send_invite_email
    TED.check_welcome_email
    check_athlete_profile
    check_athlete_accepted_status
    TED.check_accepted_email
    delete_athlete
  end
end
