# encoding: utf-8
require_relative '../test_helper'

# TS-194: Coach Regression
# UI Test: Coach RMS Login Test
class CoachRMSLoginTest < Common

  def test_coach_rms_login
  	UIActions.coach_rms_login

  	expected_title = "Search Athletes | NCSA Coach Recruiting Management System"
  	title = @browser.title
  	assert_equal expected_title, title, "Page title: #{title} - Not as expected: #{expected_title}"

  	expected_name = 'LaJay Ball'
  	user_info = @browser.element(:class, 'header__user-info')
  	user_name = user_info.element(:class, 'header__user-info__menu-button__user__data').text
  	assert_equal expected_name, user_name, "User's name: #{user_name} - Not as expected #{expected_name}"
  end
end
