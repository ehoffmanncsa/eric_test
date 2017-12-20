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
    UIActions.ted_coach_login; sleep 5

    # go to administration -> staff
    @browser.find_element(:css, 'a.icon.administration').click
    @browser.find_element(:id, 'react-tabs-4').click; sleep 1

    # find add staff button and click
    @browser.find_elements(:tag_name, 'button').each do |e|
      e.text == 'Add Staff' ? (e.click; sleep 1) : next
    end

    # fill out staff info
    UIActions.wait(30) { @browser.find_elements(:tag_name, 'input')[4].displayed? }
    @browser.find_elements(:tag_name, 'input')[0].send_keys MakeRandom.name         # first name
    @browser.find_elements(:tag_name, 'input')[1].send_keys MakeRandom.name         # last name
    @browser.find_elements(:tag_name, 'input')[2].send_keys coach_email             # email
    @browser.find_elements(:tag_name, 'input')[3].send_keys MakeRandom.number(10)   # phone
    @browser.find_elements(:tag_name, 'input')[4].send_keys position                # position

    # find add coach button and click
    # not sure why but without recognizing the text, the button won't click
    @browser.find_elements(:tag_name, 'button').each do |e|
      e.text == 'Add Coach' ? (e.click; sleep 1) : next
    end

    # use keyword password to look for password in email
    msg = @gmail.parse_body('password', from: @gmail.sender)
    coach_password = msg[1].split(':').last.split()[0]

    # signout
    sidebar = @browser.find_element(:class, 'sidebar')
    sidebar.find_element(:class, 'signout').click

    [coach_email, coach_password, position]
  end

  def test_new_added_coach
    username, password, position = add_a_coach; sleep 2
    UIActions.ted_coach_login(username, password); sleep 5

    modal = @browser.find_element(:class, 'modal-content')
    modal.find_elements(:tag_name, 'input')[0].send_keys 'ncsa'
    modal.find_elements(:tag_name, 'input')[1].send_keys 'ncsa'
    modal.find_element(:tag_name, 'button').click; sleep 1

    # go to administration -> staff
    # since first name, last name and position are the same text
    # find newly added coach by position
    @browser.find_element(:css, 'a.icon.administration').click
    @browser.find_element(:id, 'react-tabs-4').click; sleep 1
    assert (@browser.page_source.include? position), 'Did not find new coach based on his position'

    # Right now commenting this out, unable to click on cog to delete coach
    # table = @browser.find_element(:css, 'table.table')
    # row = table.find_elements(:tag_name, 'tr').last

    # cog = row.find_elements(:tag_name, 'td').last.find_element(:class, 'fa-cog')
    # pp cog.displayed?; sleep 2
    # pp cog.inspect
    # cog.click; sleep 10
  end
end