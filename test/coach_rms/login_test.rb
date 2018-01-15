# encoding: utf-8
require_relative '../test_helper'

# TS-194: Coach Regression
# UI Test: Coach RMS Login Test
class CoachRMSLoginTest < Minitest::Test
  def setup    
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
  end

  def teardown
    @browser.close
  end

  def test_coach_rms_login
  	UIActions.coach_rms_login

  	expected_title = "Home | NCSA Coach Recruiting Management System"
  	title = @browser.title
  	assert_equal expected_title, title, "Page title: #{title} - Not as expected: #{expected_title}"

  	expected_name = 'LaJay Ball'
  	user_info = @browser.element(:class, 'header__user-info')
  	user_name = user_info.element(:class, 'header__user-info__menu-button__user__data').text
  	assert_equal expected_name, user_name, "User's name: #{user_name} - Not as expected #{expected_name}"
  end
end