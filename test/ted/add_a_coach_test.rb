# encoding: utf-8
require_relative '../test_helper'

# TS-189: TED Regression
# UI Test: Add a Coach
class TEDAddACoachTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Welcome'
    @gmail.sender = 'TeamEdition@ncsasports.org'
  end

  def teardown
    @browser.close
  end

  # add a coach and get back his email, password, and position
  # not sure why cannot find elements by id or xpath
  # hence using tag name
  def add_a_coach
    position = MakeRandom.name
    coach_email = MakeRandom.email
    UIActions.ted_coach_login; sleep 3

    # go to administration -> staff
    Watir::Wait.until { @browser.element(:class, 'logo').visible? }
    @browser.element(:css, 'a.icon.administration').click; sleep 0.5
    @browser.element(:id, 'react-tabs-4').click; sleep 2

    # find add staff button and click
    @browser.elements(:tag_name, 'button').each do |e|
      e.text == 'Add Staff' ? (e.click; sleep 1) : next
    end
    Watir::Wait.until { @browser.element(:class, 'modal-content').visible? }

    # fill out staff info
    inputs = @browser.elements(:tag_name, 'input').to_a
    inputs[0].send_keys MakeRandom.name         # first name
    inputs[1].send_keys MakeRandom.name         # last name
    inputs[2].send_keys coach_email             # email
    inputs[3].send_keys MakeRandom.number(10)   # phone
    inputs[4].send_keys position                # position

    # find add coach button and click
    # not sure why but without recognizing the text, the button won't click
    @browser.elements(:tag_name, 'button').each do |e|
      e.text == 'Add Coach' ? e.click : next
    end

    # use keyword password to look for password in email
    msg = @gmail.parse_body('password', from: @gmail.sender)
    coach_password = msg[1].split(':').last.split()[0]

    # signout
    sidebar = @browser.element(:class, 'sidebar')
    sidebar.element(:class, 'signout').click

    [coach_email, coach_password, position]
  end

  def test_new_added_coach
    username, password, position = add_a_coach
    UIActions.ted_coach_login(username, password); sleep 3

    modal = @browser.element(:class, 'modal-content')
    inputs = modal.elements(:tag_name, 'input').to_a
    inputs[0].send_keys 'ncsa'
    inputs[1].send_keys 'ncsa'
    modal.element(:tag_name, 'button').click

    # go to administration -> staff
    # since first name, last name and position are the same text
    # find newly added coach by position
    @browser.element(:css, 'a.icon.administration').click; sleep 0.5
    @browser.element(:id, 'react-tabs-4').click; sleep 2
    assert (@browser.html.include? position), 'Did not find new coach based on his position'

    # Right now commenting this out, unable to click on cog to delete coach
    # table = @browser.element(:css, 'table.table')
    # row = table.elements(:tag_name, 'tr').last

    # cog = row.elements(:tag_name, 'td').last.element(:class, 'fa-cog')
    # pp cog.displayed?; sleep 2
    # pp cog.inspect
    # cog.click; sleep 10
  end
end