# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-261
# UI Test: Reviews Page - Testimonials
class TestimonialsPageTest < Minitest::Test
  def setup
    config = YAML.load_file('config/config.yml')
    @review_page = config['pages']['review_page']
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

  def goto_testimonials
    @browser.get @review_page
    nav_bar = @browser.find_element(:id, 'block-menu-block-25--2')
    menu = nav_bar.find_element(:class, 'menu')
    menu.find_element(:class, 'menu-mlid-6118').click

    str = "How do families use NCSA? | 400+ NCSA reviews"
    msg = "Browser title: #{@browser.title} is not as expected: #{str}"
    assert_equal str, @browser.title, msg

    # scroll down to trigger image loading first
    @browser.find_elements(:class, 'container').last.location_once_scrolled_into_view
    sleep 0.5
  end

  def test_testimonials_page
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-261 Test Testimonials Page', width, height
      goto_testimonials

      # check footer
      subfooter = UIActions.get_subfooter
      UIActions.check_subfooter_msg(subfooter, size.keys[0].to_s)

      # Take snapshot review page with applitool eyes
      @eyes.screenshot "Testimonials #{size.keys} view"
      result = @eyes.action.close(false)
      msg = "Testimonials #{size.keys} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def reviews_block
    @browser.find_element(:tag_name, 'header').location_once_scrolled_into_view; sleep 0.5
    group_slices = @browser.find_element(:class, 'group-slices')
    group_slices.find_element(:class, 'view-Testimonials2')
  end

  def review_rows
    content = reviews_block.find_element(:class, 'view-content')
    content.location_once_scrolled_into_view; sleep 1

    content.find_elements(:class, 'views-row')
  end

  def test_show_more_reviews
    goto_testimonials
    original_count = review_rows.length

    # find Show More button and click it
    list = reviews_block.find_element(:class, 'item-list')
    list.find_element(:tag_name, 'a').click; sleep 0.5

    more_count = review_rows.length
    assert (more_count > original_count), 'Show More button doesnt display more reviews'
  end

  def test_filter_sport_with_reviews
    goto_testimonials
    view = reviews_block.find_element(:class, 'view-filters')
    dropdown = view.find_element(:id, 'edit-field-sport-name-select-value')
    dropdown.click; sleep 0.5

    option = dropdown.find_elements(:tag_name, 'option')[1] # Baseball
    option_text = option.text.downcase
    option.click; sleep 1

    review = review_rows.sample
    sub_header = review.find_element(:class, 'group-subheader')
    sport = sub_header.find_element(:class, 'field-name-field-sport-name-select').text.downcase
    assert_equal option_text, sport, "Sport type #{sport} not matching filter #{option_text}"
  end

  def test_filter_sport_without_reviews
    goto_testimonials
    view = reviews_block.find_element(:class, 'view-filters')
    dropdown = view.find_element(:id, 'edit-field-sport-name-select-value')
    dropdown.click; sleep 0.5

    option = dropdown.find_elements(:tag_name, 'option')[18] # Women's Diving
    option.click; sleep 0.5
    msg = 'view-empty element not found for sport without reviews'
    assert reviews_block.find_element(:class, 'view-empty'), msg

    expected_msg = "Sorry – looks like we don't have any testimonials for " \
                   "this sport yet. Please select a different sport."
    actual_msg = reviews_block.find_element(:class, 'view-empty').find_element(:tag_name, 'p').text
    assert_equal expected_msg, actual_msg, 'view-empty view not displaying expected message'
  end

  def test_write_testimonial_modal
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-261 Test Write a Testimonial Modal', width, height
      goto_testimonials
      modal_wrapper = reviews_block.find_element(:class, 'write-a-testimonial-wrapper')
      modal_wrapper.find_element(:class, 'button--new-orange').click; sleep 0.5
      modal = @browser.find_element(:class, 'mfp-content')

      # Take snapshot review page with applitool eyes
      @eyes.screenshot "Write a Testimonial Modal #{size.keys} view"
      result = @eyes.action.close(false)
      msg = "Write a Testimonial Modal #{size.keys} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure    
  end
end