# encoding: utf-8
require_relative '../test_helper'

# TS-189: TED Regression
# UI Test: Add/Delete a Coach

=begin
  This test use coach admin Tiffany of Awesome Sauce organization
  Coach admin add new coach in UI via Administration page Staff tab
  Make sure his name is found in Staff table after added
  Class GmailCalls helps connect to ncsa.automation@gmail.com account
  In this gmail account we find Invitation email in TED_Welcome mailbox
  Get the tempt password for new coach in this email and delete email
  Login as new coach to make sure he was successfully created
  Make sure there is prompt to reset password
  Delete the new coach afterward and make sure his name is no longer in UI
=end

class TEDAddDeleteACoachTest < Common
  def setup
    super
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Welcome'
    @gmail.sender = 'TeamEdition@ncsasports.org'

    @token = TEDAuth.new('prem_coach').get_token
    @api = Api.new
  end

  def teardown
    super
  end

  def add_a_coach
    firstname = MakeRandom.first_name
    lastname = MakeRandom.last_name
    phone = MakeRandom.phone_number
    position = MakeRandom.name

    @coach_name = "#{firstname} #{lastname}"
    @coach_email = MakeRandom.email
    pp "Adding coach name: #{@coach_name}"

    UIActions.ted_login
    TED.go_to_staff_tab

    # find add staff button and click to open modal
    # fill out staff info in modal
    @browser.button(text: 'Add Staff').click
    Watir::Wait.until { TED.modal.present? }; sleep 0.5
    inputs = TED.modal.elements(tag_name: 'input').to_a
    inputs[0].send_keys firstname
    inputs[1].send_keys lastname
    inputs[2].send_keys @coach_email
    inputs[3].send_keys phone
    inputs[4].send_keys position
    TED.modal.button(text: 'Add Coach').click
    UIActions.wait_for_modal
  end

  def get_coach_password
    # use keyword 'password' to look for password in gmail
    emails = @gmail.get_unread_emails
    msg = @gmail.parse_body(emails.last, 'password')
    password = msg.split(':').last.split()[0]
    @gmail.delete(emails)

    password
  end

  def set_new_password
    Watir::Wait.until {  TED.modal.present? }
    assert TED.modal, 'Set new password modal not found'

    inputs = TED.modal.elements(tag_name: 'input').to_a
    inputs[0].send_keys 'ncsa'
    inputs[1].send_keys 'ncsa'
    TED.modal.element(tag_name: 'button').click

    UIActions.wait_for_modal
  end

  def check_new_coach_can_login
    TED.sign_out
    UIActions.ted_login(@coach_email, get_coach_password)
    set_new_password
    TED.sign_out
  end

  def delete_coach
    UIActions.ted_login
    TED.go_to_staff_tab; sleep 0.5

    row = TED.get_row_by_name(@coach_name)
    cog = row.elements(tag_name: 'td').last.element(class: 'fa-cog')
    cog.click; sleep 1
    TED.modal.button(text: 'Delete Staff Member').click; sleep 1
  end

  def test_add_delete_coach
    add_a_coach
    msg = "Cannot find newly added Coach #{@coach_name}"
    assert (@browser.element(text: @coach_name).present?), msg

    check_new_coach_can_login
    delete_coach
    msg = 'Found deleted coach in UI'
    refute (@browser.html.include? "#{@coach_name}"), msg
  end
end
