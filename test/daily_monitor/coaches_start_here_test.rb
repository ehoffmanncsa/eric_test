# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-325
# UI Test: Daily Monitor - Coaches Start Here
class CoachesStartHereTest < Minitest::Test
  def setup
    config = YAML.load_file('old_config/config.yml')
    @homepage = config['pages']['home_page']
    @viewports = [
      { ipad: config['viewport']['ipad'] },
      { iphone: config['viewport']['iphone'] },
      { desktop: config['viewport']['desktop'] }
    ]
    @eyes = Applitool.new 'Content'
    @ui = UI.new 'browserstack', 'chrome'
    @browser = @ui.driver
    UIActions.setup(@browser)
  end

  def teardown
    @browser.quit
  end

  def goto_coach_start_here
    @browser.get @homepage
    @browser.find_element(:class, 'button--coach').click
  end

  def test_coaches_start_here_page
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-325 Coaches Start Here Page', width, height
      goto_coach_start_here
      str = 'NCSA Login for College, Club and HS Coaches'
      title = @browser.title
      assert_equal str, title, "Browser title: #{title} - Not as expected: #{str}"

      @browser.find_elements(:class, 'container').last.location_once_scrolled_into_view; sleep 0.5

      subfooter = UIActions.get_subfooter
      UIActions.check_subfooter_msg(subfooter, size.keys[0].to_s)

      # Take snapshot review page with applitool eyes
      @eyes.screenshot "Coaches Start Here #{size.keys} view"
      result = @eyes.action.close(false)
      failure << "Coaches Start Here #{size.keys} - #{result.mismatches} mismatches found" unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_college_coach_sign_in_button
    goto_coach_start_here
    button = @browser.find_element(:class, 'button--athlete')
    expected_url = 'http://coach.ncsasports.org/coach/coachrms/login'
    url = button.attribute('href')
    assert_equal expected_url, url, 'Login url for Coach RMS is incorrect'

    button.click
    expected_title = "College Coach Login | NCSA Coach Recruiting Management System"
    title = @browser.title
    assert_equal expected_title, title, 'Incorrect page title for Coach RMS Login'
  end

  def test_hs_coach_sign_in_button
    goto_coach_start_here
    button = @browser.find_element(:class, 'button--primary')
    expected_url = 'https://team.ncsasports.org/sign_in'
    url = button.attribute('href')
    assert_equal expected_url, url, 'Login url for HS Coach is incorrect'

    button.click
    expected_title = "Team Edition | Recruiting Management System"
    title = @browser.title
    assert_equal expected_title, title, 'Incorrect page title for HS Coach Login'
  end
end
