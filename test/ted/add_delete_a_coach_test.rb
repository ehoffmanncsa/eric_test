# encoding: utf-8
require_relative '../test_helper'

# TS-189: TED Regression
# UI Test: Add/Delete a Coach
class TEDAddDeleteACoachTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Welcome'
    @gmail.sender = 'TeamEdition@ncsasports.org'

    @token = TEDAuth.new('coach').get_token
    @api = Api.new
  end

  def teardown
    @browser.close
  end

  def add_a_coach
    @coach_email = MakeRandom.email
    @phone = MakeRandom.number(10)
    @firstname = MakeRandom.name
    @lastname = MakeRandom.name
    @position = MakeRandom.name

    UIActions.ted_coach_login
    TED.go_to_staff_tab

    # find add staff button and click to open modal
    # fill out staff info in modal
    @browser.button(:text, 'Add Staff').click; sleep 1
    Watir::Wait.until { @browser.element(:class, 'modal-content').present? }
    modal = @browser.element(:class, 'modal-content')
    inputs = modal.elements(:tag_name, 'input').to_a
    inputs[0].send_keys @firstname
    inputs[1].send_keys @lastname
    inputs[2].send_keys @coach_email
    inputs[3].send_keys @phone
    inputs[4].send_keys @position
    modal.button(:text, 'Add Coach').click; sleep 5
  end

  def get_coach_password
    # use keyword 'password' to look for password in gmail
    emails = @gmail.get_unread_emails
    msg = @gmail.parse_body(emails, 'password')
    password = msg[1].split(':').last.split()[0]
    @gmail.delete(emails)

    password
  end

  def set_new_password
    Watir::Wait.until { @browser.element(:class, 'modal-content').present? }
    modal = @browser.element(:class, 'modal-content')
    assert modal, 'Set new password modal not found'

    inputs = modal.elements(:tag_name, 'input').to_a
    inputs[0].send_keys 'ncsa'
    inputs[1].send_keys 'ncsa'
    modal.element(:tag_name, 'button').click; sleep 1
  end

  def check_new_coach_can_login
    TED.sign_out
    UIActions.ted_coach_login(@coach_email, get_coach_password)
    set_new_password
    TED.sign_out
  end

  def delete_coach
    UIActions.ted_coach_login
    TED.go_to_staff_tab
    id = TED.get_coach_id(@coach_email)

    tab = @browser.div(:id, 'react-tabs-5')
    table = tab.element(:class, 'table')
    row = table.element(:id, "coach#{id}")
    cog = row.elements(:tag_name, 'td').last.element(:class, 'fa-cog')
    cog.click; sleep 1
    modal = @browser.div(:class, 'modal-content')
    modal.button(:text, 'Delete Staff Member').click; sleep 1
  end

  def test_add_delete_coach
    add_a_coach
    msg = "Did not find coach #{@firstname} #{@lastname}"
    assert_includes @browser.html, "#{@firstname} #{@lastname}", msg

    check_new_coach_can_login
    delete_coach
    msg = 'Found deleted coach in UI'
    refute (@browser.html.include? "#{@firstname} #{@lastname}"), msg
  end
end
