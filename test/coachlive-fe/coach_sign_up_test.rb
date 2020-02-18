# frozen_string_literal: true

require_relative '../test_helper'

require 'time'
require 'date'

# UI Test: Sign up a new coach in the app and then verify that coach in fasttrack
class CoachSignUpTest < Common
  def setup
    super

    @coach_packet_config = Default.env_config['coach_packet']
    @CoachEmail = MakeRandom.fake_email
    @CoachFirst = MakeRandom.first_name
    @CoachLast = MakeRandom.last_name
    @CoachCollege = MakeRandom.alpha
    @CoachPhone = MakeRandom.phone_number
    @CoachPosition = MakeRandom.name
    @CoachTwitter = '@ncsa'

    @email = @coach_packet_config['admin_username']
    @password = @coach_packet_config['admin_password']

    UIActions.setup(@browser)
    @browser.goto 'http://coachlive-staging.ncsasports.org/login'
  end

  def adjust_window
    # adjust browser size
    width = 411
    height = 731
    @browser.window.resize_to(width, height)
  end

  def adjust_window_fasttrack
    # adjust browser size
    width = 1500
    height = 1000
    @browser.window.resize_to(width, height)
  end

  def enter_coach_email
    email = @browser.text_field(name: 'email')
    email.set @CoachEmail

    submit_button = @browser.button(text: 'NEXT')
    submit_button.click
    sleep 3
  end

  def enter_coach_info
    @browser.text_field(name: 'firstName').set @CoachFirst
    @browser.text_field(name: 'lastName').set @CoachLast
    @browser.text_field(name: 'phone').set @CoachPhone
    @browser.text_field(name: 'position').set @CoachPosition
    @browser.text_field(name: 'twitter').set @CoachTwitter
  end

  def select_college
    @browser.text_field(name: 'college').set @CoachCollege
    sleep 3
    list = @browser.elements(tag_name: 'span').to_a
    list.sample.click
  end

  def select_sport
    @browser.element(id: 'mui-component-select-sport').click
    sleep 3
    list = @browser.elements(tag_name: 'li').to_a
    list.sample.click
  end

  def close_sports
    @browser.send_keys(:escape)
  end

  def submit_data
    submit_button = @browser.button(text: 'SIGN UP')
    submit_button.click
  end

  def compare_coach_sign_up_coach_admin
    failure = []

    failure << "Incorrect coach email #{@CoachEmail}" unless @browser.html.include? @CoachEmail
    failure << "Incorrect coach first name #{@CoachFirst}" unless @browser.html.include? @CoachFirst
    failure << "Incorrect coach last name #{@Coachlast}" unless @browser.html.include? @CoachLast
    failure << "Incorrect college #{@CoachCollege}" unless @browser.html.include? @CoachCollege
    failure << "Incorrect coach position #{@CoachPosition}" unless @browser.html.include? @CoachPosition
    assert_empty failure
  end

  def search_college_coach_first
    @browser.element(name: 'first_name').send_keys @CoachFirst
  end

  def search_college_coach_last
    @browser.element(name: 'last_name').send_keys @CoachLast
  end

  def search_coach_name
    @browser.element(id: 'search-submit').click
  end

  def verify_coach
    @browser.a(text: /verify/).click
  end

  def coach_is_not_pending
    refute (@browser.html.include? @CoachLast), "Found verified coach on pending list #{@CoachLast}"
  end

  def signup_new_coach
    sleep 5
    adjust_window
    enter_coach_email
    select_college
    sleep 2
    select_sport
    sleep 2
    close_sports
    sleep 2
    enter_coach_info
    sleep 5
    submit_data
    sleep 2
  end

  def coach_admin_verify
    adjust_window_fasttrack
    CoachPacket_AdminUI.setup(@browser)
    UIActions.fasttrack_login(@email, @password)
    CoachPacket_AdminUI.goto_Coach_Packet_admin
    CoachPacket_AdminUI.select_college_coach_page
    compare_coach_sign_up_coach_admin
    search_college_coach_first
    search_college_coach_last
    search_coach_name
    sleep 5
    verify_coach
    sleep 5
    coach_is_not_pending
  end

  def test_coach_sign_up
    signup_new_coach
    coach_admin_verify
  end
end
