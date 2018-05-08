# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-263
# UI Test: Reviews Page - College Coach Reviews
class CollegeCoachReviewsTest < VisualCommon
  def setup
    super
    @review_page = Default.static_info['pages']['review_page']
    DailyMonitor.setup(@browser)
  end

  def teardown
    super
  end

  def goto_coach_reviews
    @browser.goto @review_page
    nav_bar = @browser.element(:id, 'block-menu-block-25--2')
    menu = nav_bar.element(:class, 'menu')
    menu.element(:class, 'menu-mlid-6233').click

    str = "Do College Coaches Use NCSA 99% of Colleges Used NCSA in 2016"
    msg = "Browser title: #{@browser.title} is not as expected: #{str}"
    assert_equal str, @browser.title, msg
  end

  def test_college_coach_reviews_page
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser.driver, 'TS-263 Test College Coach Reviews Page', width, height
      goto_coach_reviews

      # check footer
      DailyMonitor.subfooter.scroll.to; sleep 0.5
      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      # Take snapshot review page with applitool eyes
      @eyes.screenshot "College Coach Reviews #{size.keys} view"
      result = @eyes.action.close(false)
      msg = "College Coach Reviews #{size.keys} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_testimonials_page
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser.driver, 'TS-263 Test Testimonials Page', width, height
      goto_coach_reviews

      section = @browser.element(:class, 'node-title-reviews--do-coaches-use-ncsa-copy-block---blockquotes')
      field = section.element(:class, 'row').element(:class, 'field-name-body')
      field.elements(:tag_name, 'blockquote').last.scroll.to; sleep 0.5
      @browser.link(:text, 'testimonials page').click

      # check footer
      DailyMonitor.subfooter.scroll.to; sleep 0.5
      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      # Take snapshot review page with applitool eyes
      @eyes.screenshot "Testimonials #{size.keys} view"
      result = @eyes.action.close(false)
      msg = "Testimonials page #{size.keys} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end
end
