# encoding: utf-8
require_relative '../test_helper'
require 'securerandom'

# TS-189: TED Regression
# UI Test: Add a Coach
class TEDAddACoachTest < Minitest::Test
  def setup
    config = YAML.load_file('config/config.yml')
    @coach_login = config['TED_coach_app']['login_staging']

    creds = YAML.load_file('config/.creds.yml')
    @admin_user = creds['ted']['username']
    @admin_pwd = creds['ted']['password']
    
    @ui = LocalUI.new(true)
    @browser = @ui.driver

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Welcome'
    @gmail.sender = 'TeamEdition@ncsasports.org'
  end

  def teardown
    @browser.close
  end

  def login(username, password)
    @browser.get @coach_login
    @browser.find_elements(:tag_name, 'input')[0].send_keys username
    @browser.find_elements(:tag_name, 'input')[1].send_keys password
    @browser.find_element(:tag_name, 'button').click; sleep 1
  end

  def make_number(digits)
    charset = Array('0'..'9')
    Array.new(digits) { charset.sample }.join
  end

  # add a coach and get back his email, password, and position
  # not sure why cannot find elements by id or xpath
  # hence using tag name and array index
  def add_a_coach
    rand_text = SecureRandom.hex(3)
    coach_email = "ncsa.automation+#{rand_text}@gmail.com"
    login(@admin_user, @admin_pwd); sleep 5

    # go to administration -> staff
    @browser.find_element(:css, 'a.icon.administration').click
    @browser.find_element(:id, 'react-tabs-4').click; sleep 3

    # find add staff button and click
    # not sure why but without recognizing the text, the button won't click
    begin
      add_staff = @browser.find_elements(:tag_name, 'button')[33]; add_staff.text
      add_staff.click; sleep 1
    rescue => e
      retry
    end

    # fill out staff info
    @ui.wait(30) { @browser.find_elements(:tag_name, 'input')[4].displayed? }
    @browser.find_elements(:tag_name, 'input')[0].send_keys rand_text         # first name
    @browser.find_elements(:tag_name, 'input')[1].send_keys rand_text         # last name
    @browser.find_elements(:tag_name, 'input')[2].send_keys coach_email       # email
    @browser.find_elements(:tag_name, 'input')[3].send_keys make_number(10)   # phone
    @browser.find_elements(:tag_name, 'input')[4].send_keys rand_text         # position

    # find add coach button and click
    # not sure why but without recognizing the text, the button won't click
    add_coach = @browser.find_elements(:tag_name, 'button')[34]; add_coach.text
    add_coach.click

    # use keyword password to look for password in email
    msg = @gmail.body('password', from: @gmail.sender)
    coach_password = msg[1].split(':').last.split()[0]

    # signout
    @browser.find_element(:css, 'a.icon.signout').click

    [coach_email, coach_password, rand_text]
  end

  def test_new_added_coach
    username, password, position = add_a_coach; sleep 2
    login(username, password); sleep 3

    modal = @browser.find_element(:class, 'modal-content')
    modal.find_elements(:tag_name, 'input')[0].send_keys 'ncsa'
    modal.find_elements(:tag_name, 'input')[1].send_keys 'ncsa'
    modal.find_element(:tag_name, 'button').click; sleep 2

    # go to administration -> staff
    # since first name, last name and position are the same text
    # find newly added coach by position
    @browser.find_element(:css, 'a.icon.administration').click
    @browser.find_element(:id, 'react-tabs-4').click; sleep 3
    assert (@browser.page_source.include? position), 'Did not find new coach based on his position'

    # Right now commenting this out, unable to click on cog to delete coach
    # table = @browser.find_element(:css, 'table.table')
    # row = table.find_elements(:tag_name, 'tr').last

    # cog = row.find_elements(:tag_name, 'td').last.find_element(:class, 'fa-cog')
    # pp cog.displayed?; sleep 2
    # pp cog.inspect
    #cog.click; sleep 10
  end
end