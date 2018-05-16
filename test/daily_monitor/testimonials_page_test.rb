# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-261
# UI Test: Reviews Page - Testimonials
class TestimonialsPageTest < VisualCommon
  def setup
    super
  end

  def teardown
    super
  end

  def goto_testimonials
    DailyMonitor.goto_page('review_page')

    nav_bar = @browser.element(:id, 'block-menu-block-25--2')
    menu = nav_bar.element(:class, 'menu')
    menu.element(:class, 'menu-mlid-6118').click

    title = 'How do families use NCSA? | 400+ NCSA reviews'
    assert_equal title, @browser.title, 'Incorrect page title'
  end

  def test_testimonials_page
    goto_testimonials
    DailyMonitor.subfooter.scroll.to; sleep 0.5

    failure = []
    @viewports.each do |size|
      open_eyes("TS-261 Test Testimonials Page - #{size.keys[0]}", size)

      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      @eyes.screenshot "Testimonials #{size.keys[0]} view"

      result = @eyes.action.close(false)
      msg = "Testimonials #{size.keys[0]} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def reviews_block
    group_slice = @browser.element(:class, 'group-slices')
    group_slice.element(:class, 'view-Testimonials2')
  end

  def review_rows
    content = reviews_block.element(:class, 'view-content')
    content.elements(:class, 'views-row').to_a
  end

  def test_show_more_reviews
    goto_testimonials

    original_count = review_rows.length

    # find Show More button and click it
    reviews_block.link(:text, 'Show More').click; sleep 0.5

    more_count = review_rows.length
    assert (more_count > original_count), 'Show More button doesnt display more reviews'
  end

  def test_filter_sport_with_reviews
    goto_testimonials

    # filter by Baseball
    dropdown = reviews_block.select_list(:id, 'edit-field-sport-name-select-value')
    dropdown.select 'baseball'; sleep 1

    review = review_rows.sample
    sub_header = review.element(:class, 'group-subheader')
    sport = sub_header.element(:class, 'field-name-field-sport-name-select').text.downcase
    assert_equal 'baseball', sport, "Sport type #{sport} not matching filter Baseball"
  end

  def test_filter_sport_without_reviews
    goto_testimonials

    # filter by Women's Diving
    dropdown = reviews_block.select_list(:id, 'edit-field-sport-name-select-value')
    dropdown.select 'womens-diving'; sleep 1

    msg = 'view-empty element not found for sport without reviews'
    assert reviews_block.element(:class, 'view-empty'), msg

    expected_msg = "Sorry – looks like we don't have any testimonials for " \
                   "this sport yet. Please select a different sport."
    actual_msg = reviews_block.element(:class, 'view-empty').element(:tag_name, 'p').text
    assert_equal expected_msg, actual_msg, 'view-empty view not displaying expected message'
  end

  def test_write_testimonial_modal
    goto_testimonials
    #@eyes.eyes.force_full_page_screenshot = false

    failure = []

    @viewports.each do |size|
      open_eyes("TS-261 Test Write a Testimonial Modal - #{size.keys[0]}", size)

      # open modal
      modal_wrapper = reviews_block.element(:class, 'write-a-testimonial-wrapper')
      modal_wrapper.element(:class, 'button--new-orange').click; sleep 0.5
      modal = @browser.element(:class, 'mfp-content')

      @eyes.screenshot "Write a Testimonial Modal #{size.keys[0]} view"

      modal.button(:class, 'mfp-close').click # close modal

      result = @eyes.action.close(false)
      msg = "Write a Testimonial Modal #{size.keys[0]} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end
end
