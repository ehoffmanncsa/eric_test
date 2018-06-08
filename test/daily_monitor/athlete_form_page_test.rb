# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor
# UI Test: Daily Monitor - Athlete Start Here Page
class AthleteFormPageTest < VisualCommon
  def setup
    super
  end

  def teardown
    super
  end

  def goto_athlete_form
    DailyMonitor.goto_page('home_page')
    @browser.element(:class, 'button--athlete').click
  end

  def test_redir_from_desktop_homepage
    goto_athlete_form

    title = 'NCSA Athletic Recruiting | Play Sports in College'
    assert_equal title, @browser.title, 'Incorrect page title'

    #assert (@browser.url.include? 'NW_Partners'), 'URL not including NW_Partners'
  end

  def test_redir_from_mobile_homepage
    # Using Ipad viewport size
    size = @viewports[1]
    DailyMonitor.resize_browser(size)

    goto_athlete_form

    title = 'NCSA Athletic Recruiting | Play Sports in College'
    assert_equal title, @browser.title, 'Incorrect page title'

    #assert (@browser.url.include? 'WWW_Mobile'), 'URL not including WWW_Mobile'
  end

  def test_athlete_form_visual
    goto_athlete_form

    failure = []
    @viewports.each do |size|
      open_eyes("Athlete Form - #{size.keys[0]}", size)

      @eyes.screenshot "#{size.keys[0]} view"

      result = @eyes.action.close(false)
      msg = "Athlete Form #{size.keys[0]} view - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end
end
