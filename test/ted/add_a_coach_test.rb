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

  def go_to_staff_tab
    # go to administration -> staff
    Watir::Wait.until { @browser.element(:class, 'sidebar').visible? }
    @browser.link(:text, 'Administration').click
    Watir::Wait.until { @browser.element(:id, 'react-tabs-1').visible? }
    @browser.element(:id, 'react-tabs-4').click
    Watir::Wait.until { @browser.element(:id, 'react-tabs-5').visible? }
  end

  # add a coach and get back his email, password, and position
  # not sure why cannot find elements by id or xpath
  # hence using tag name
  def add_a_coach
    position = MakeRandom.name
    coach_email = MakeRandom.email
    UIActions.ted_coach_login
    go_to_staff_tab

    # find add staff button and click
    @browser.button(:text, 'Add Staff').click

    # fill out staff info
    Watir::Wait.until { @browser.element(:class, 'modal-content').visible? }
    modal = @browser.element(:class, 'modal-content')
    inputs = modal.elements(:tag_name, 'input').to_a
    inputs[0].send_keys MakeRandom.name         # first name
    inputs[1].send_keys MakeRandom.name         # last name
    inputs[2].send_keys coach_email             # email
    inputs[3].send_keys MakeRandom.number(10)   # phone
    inputs[4].send_keys position                # position
    modal.button(:text, 'Add Coach').click

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
    UIActions.ted_coach_login(username, password)
    Watir::Wait.until { @browser.element(:class, 'graphs').exists? }

    Watir::Wait.until { @browser.element(:class, 'modal-content').exists? }
    modal = @browser.element(:class, 'modal-content'); sleep 1
    inputs = modal.elements(:tag_name, 'input').to_a
    inputs[0].send_keys 'ncsa'
    inputs[1].send_keys 'ncsa'
    modal.element(:tag_name, 'button').click

    # since first name, last name and position are the same text
    # find newly added coach by position
    go_to_staff_tab
    assert (@browser.html.include? position), 'Did not find new coach based on his position'

    # Right now commenting this out, unable to click on cog to delete coach
    # table = @browser.element(:css, 'table.table')
    # row = table.elements(:tag_name, 'tr').last

    # cog = row.elements(:tag_name, 'td').last.element(:class, 'fa-cog')
    # pp cog.visible?; sleep 2
    # pp cog.inspect
    # unhide = "arguments[0].aria-hidden='false'"; sleep 30
    # @browser.execute_script(unhide, cog); sleep 3
    # pp cog.visible?
    # cog.click; sleep 10
  end
end