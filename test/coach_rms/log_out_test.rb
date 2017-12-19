# encoding: utf-8
require_relative '../test_helper'

# TS-276: Coach Regression
# UI Test: Coach RMS Logout Test
class CoachRMSLogoutTest < Minitest::Test
  def setup    
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
  end

  def teardown
    @browser.quit
  end

  def test_coach_rms_logout
  	UIActions.coach_rms_login
  	user_info = @browser.find_element(:class, 'header__user-info')
  	menu = user_info.find_element(:class, 'header__user-info__menu-button')

    menu.click; sleep 0.5
    list = menu.find_element(:class, 'header__user-info__list')
    logout = list.find_elements(:tag_name, 'li').last
    logout.find_element(:tag_name, 'a').click

    expected_url = 'http://coach-qa.ncsasports.org/coach/coachrms/login'
    url = @browser.current_url
    assert_equal expected_url, url, 'Logout not redir to login page'
  end
end