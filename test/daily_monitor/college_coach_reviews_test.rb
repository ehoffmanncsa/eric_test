# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-263
# UI Test: Reviews Page - College Coach Reviews
class CollegeCoachReviewsTest < Minitest::Test
  def setup
    config = YAML.load_file('config/config.yml')
    @review_page = config['pages']['review_page']
    @viewports = [
      { ipad: config['viewport']['ipad'] },
      { iphone: config['viewport']['iphone'] },
      { desktop: config['viewport']['desktop'] }
    ]
    @eyes = Applitool.new 'Content'
    @ui = UI.new 'local', 'chrome'
    @browser = @ui.driver
    UIActions.setup(@browser)
  end

  def teardown
    @browser.quit
  end

  def goto_coach_reviews
    @browser.get @review_page
    nav_bar = @browser.find_element(:id, 'block-menu-block-25--2')
    menu = nav_bar.find_element(:class, 'menu')
    menu.find_element(:class, 'menu-mlid-6233').click

    str = "Do College Coaches Use NCSA 99% of Colleges Used NCSA in 2016"
    msg = "Browser title: #{@browser.title} is not as expected: #{str}"
    assert_equal str, @browser.title, msg

    # scroll down to trigger image loading first
    @browser.find_elements(:class, 'container').last.location_once_scrolled_into_view
    sleep 0.5
  end

  def test_college_coach_reviews_page
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-263 Test College Coach Reviews Page', width, height
      goto_coach_reviews

      # check footer
      subfooter = UIActions.get_subfooter
      UIActions.check_subfooter_msg(subfooter, size.keys[0].to_s)

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

      @eyes.open @browser, 'TS-263 Test Testimonials Page', width, height
      goto_coach_reviews
      section = @browser.find_element(:class, 'node-title-reviews--do-coaches-use-ncsa-copy-block---blockquotes')
      field = section.find_element(:class, 'row').find_element(:class, 'field-name-body')
      field.find_elements(:tag_name, 'blockquote').last.location_once_scrolled_into_view
      sleep 0.5
      @browser.find_element(:link_text, 'testimonials page').click

      # scroll down to trigger image loading first
      @browser.find_elements(:class, 'container').last.location_once_scrolled_into_view
      sleep 0.5

      # check footer
      subfooter = UIActions.get_subfooter
      UIActions.check_subfooter_msg(subfooter, size.keys[0].to_s)

      # Take snapshot review page with applitool eyes
      @eyes.screenshot "Testimonials #{size.keys} view"
      result = @eyes.action.close(false)
      msg = "Testimonials page #{size.keys} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end
end