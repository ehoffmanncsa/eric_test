# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor
# UI Test: Daily Monitor - Parents Start Here Page
class ParentFormPageTest < VisualCommon
  def setup
    super
  end

  def teardown
    super
  end

  def goto_parent_form
    DailyMonitor.goto_page('home_page')
    @browser.element(:class, 'button--parent').click
  end

  def test_redir_from_desktop_homepage
    goto_parent_form

    title = 'NCSA Athletic Recruiting | Play Sports in College'
    assert_equal title, @browser.title, 'Incorrect page title'

    #assert (@browser.url.include? 'NW_Partners'), 'URL not including NW_Partners'
  end

  def test_redir_from_mobile_homepage
    # Using Ipad viewport size
    size = @viewports[1]
    @browser.window.resize_to(DailyMonitor.width(size), DailyMonitor.height(size))

    goto_parent_form

    title = 'NCSA Athletic Recruiting | Play Sports in College'
    assert_equal title, @browser.title, 'Incorrect page title'

    #assert (@browser.url.include? 'WWW_Mobile'), 'URL not including WWW_Mobile'
  end

  def test_parent_form_visual
    goto_parent_form

    failure = []
    @viewports.each do |size|
      open_eyes("Parent Form - #{size.keys[0]}", size)

      @eyes.screenshot "#{size.keys[0]} view"

      result = @eyes.action.close(false)
      msg = "Parent Form #{size.keys[0]} view - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end
end
