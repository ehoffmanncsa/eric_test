# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-325
# UI Test: Daily Monitor - Coaches Start Here
class CoachesStartHereTest < VisualCommon
  def setup
    super
  end

  def teardown
    super
  end

  def goto_coach_start_here
    DailyMonitor.goto_page('home_page')
    @browser.element(:class, 'button--coach').click
  end

  def test_coaches_start_here_page
    goto_coach_start_here

    title = 'NCSA Login for College, Club and HS Coaches'
    assert_equal title, @browser.title, 'Incorrect page title'

    DailyMonitor.subfooter.scroll.to; sleep 0.5

    failure = []

    @viewports.each do |size|
      open_eyes("TS-325 Coaches Start Here Page - #{size.keys[0]}", size)

      title = 'NCSA Login for College, Club and HS Coaches'
      assert_equal title, @browser.title, 'Incorrect page title'

      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      @eyes.screenshot "Coaches Start Here #{size.keys} view"

      result = @eyes.action.close(false)
      msg = "Coaches Start Here #{size.keys[0]} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_college_coach_sign_in_button
    goto_coach_start_here

    button = @browser.element(:class, 'button--athlete')

    expected_url = 'http://coach.ncsasports.org/coach/coachrms/login'
    url = button.attribute('href')
    assert_equal expected_url, url, 'Login url for Coach RMS is incorrect'

    button.click

    title = 'College Coach Login | NCSA Coach Recruiting Management System'
    assert_equal title, @browser.title, 'Incorrect page title for Coach RMS Login'
  end

  def test_hs_coach_sign_in_button
    goto_coach_start_here

    button = @browser.element(:class, 'button--primary')

    expected_url = 'https://team.ncsasports.org'
    url = button.attribute('href')
    assert_equal expected_url, url, 'Login url for HS Coach is incorrect'

    button.click

    title = 'Team Edition | Recruiting Management System'
    assert_equal title, @browser.title, 'Incorrect page title for TED Login'
  end
end
