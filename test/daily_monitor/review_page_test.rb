# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-120
# UI Test: Daily Monitor - Review Page
class ReviewPageMonitorTest < VisualCommon
  def setup
    super
  end

  def teardown
    super
  end

  # Start a applitool eye test session
  # Within the session loop through different viewport size
  # and navigate to review page, verify page title
  def test_review_page_views
    DailyMonitor.goto_page('review_page')

    title = '400+ NCSA Reviews from Parents, Athletes and College Coaches'
    assert_equal title, @browser.title, 'Incorrect page title'

    DailyMonitor.subfooter.scroll.to; sleep 0.5

    failure = []

    @viewports.each do |size|
      open_eyes("TS-120 Test Review Page - #{size.keys[0]}", size)

      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      @eyes.screenshot "Review page #{size.keys[0]} view"

      unless size.keys.to_s =~ /desktop/
        DailyMonitor.hamburger_menu.click # open
        @eyes.screenshot "#{size.keys[0]} view with hamburger menu open"
        DailyMonitor.hamburger_menu.click # close
      end

      result = @eyes.action.close(false)
      msg = "Review page #{size.keys[0]} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end
end
