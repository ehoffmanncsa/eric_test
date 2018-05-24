# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-263
# UI Test: Reviews Page - College Coach Reviews
class CollegeCoachReviewsTest < VisualCommon
  def setup
    super
  end

  def teardown
    super
  end

  def goto_coach_reviews
    DailyMonitor.goto_page('review_page')

    nav_bar = @browser.element(:id, 'block-menu-block-25--2')
    menu = nav_bar.element(:class, 'menu')
    menu.element(:class, 'menu-mlid-6233').click

    title = "Do College Coaches Use NCSA 99% of Colleges Used NCSA in 2016"
    assert_equal title, @browser.title, 'Incorrect page title'
  end

  def test_college_coach_reviews_page
    goto_coach_reviews
    DailyMonitor.subfooter.scroll.to; sleep 0.5

    failure = []
    @viewports.each do |size|
      open_eyes( "TS-263 Test College Coach Reviews Page - #{size.keys[0]}", size)

      # check footer
      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      @eyes.screenshot "College Coach Reviews #{size.keys[0]} view"

      result = @eyes.action.close(false)
      msg = "College Coach Reviews #{size.keys[0]} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_testimonials_page
    goto_coach_reviews

    @browser.link(:text, 'testimonials page').click
    DailyMonitor.subfooter.scroll.to; sleep 0.5

    failure = []
    @viewports.each do |size|
      open_eyes("TS-263 Test Testimonials Page - #{size.keys[0]}", size)

      # check footer
      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      # Take snapshot review page with applitool eyes
      @eyes.screenshot "Testimonials #{size.keys[0]} view"

      result = @eyes.action.close(false)
      msg = "Testimonials page #{size.keys[0]} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end
end
