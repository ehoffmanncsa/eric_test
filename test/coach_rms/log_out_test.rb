# encoding: utf-8
require_relative '../test_helper'

# TS-276: Coach Regression
# UI Test: Coach RMS Logout Test
class CoachRMSLogoutTest < Common

  def test_coach_rms_logout
    skip
  	UIActions.coach_rms_login
  	user_info = @browser.element(:class, 'header__user-info')
  	menu = user_info.element(:class, 'header__user-info__menu-button')

    menu.click
    list = menu.element(:class, 'header__user-info__list')
    logout = list.elements(:tag_name, 'li').last
    logout.element(:tag_name, 'a').click

    expected_url = 'http://coach-qa.ncsasports.org/coach/coachrms/login'
    url = @browser.url
    assert_equal expected_url, url, 'Logout not redir to login page'
  end
end
