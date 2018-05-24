# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-262
# UI Test: Reviews Page - Alumni Reviews
class AlumniReviewsTest < VisualCommon
  def setup
    super
  end

  def teardown
    super
  end

  def goto_alumni_reviews
    DailyMonitor.goto_page('review_page')

    nav_bar = @browser.element(:id, 'block-menu-block-25--2')
    nav_bar.link(:text, 'Our Recruiting Coaches').click

    title = 'Meet NCSA’s team of 600+ former college and pro athletes'
    assert_equal title, @browser.title, 'Incorrect page title'
  end

  def test_alumni_reviews_page
    goto_alumni_reviews
    DailyMonitor.subfooter.scroll.to; sleep 0.5

    failure = []

    @viewports.each do |size|
      open_eyes("TS-262 Test Alumni Reviews Page - #{size.keys[0]}", size)

      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      @eyes.screenshot "Alumni Reviews #{size.keys[0]} view"

      result = @eyes.action.close(false)
      msg = "Alumni Reviews #{size.keys[0]} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_alumni_page_videos_popup
    goto_alumni_reviews

    section = @browser.element(:class, 'node-title-meet-the-former-college-players--coaches-ready-to-help-you')
    field = section.element(:class, 'row').element(:class, 'field-name-field-dices')
    videos = field.elements(:class, 'field-name-field-image')

    # go though each video, check if the url gives 200
    # if 200 click on it, make sure there is popup and popup url has matching video id
    # if not dont bother
    failure = []

    videos.each do |vid|
      url = vid.element(:tag_name, 'a').attribute('href')
      url_id = url.split('=')[1]

      resp = DailyMonitor.get_url_response(url)

      unless resp.eql? 200
        failure << "Video id #{url_id} gives #{resp}"
        next
      end

      vid.click
      popup = @browser.element(:class, 'mfp-content')
      iframe = popup.element(:class, 'mfp-iframe')

      unless iframe.present?
        failure << "Video id #{url_id} no popup"
        next
      end

      src = iframe.attribute('src')
      src_id = src.split('/').last.split('?')[0]
      failure << "youtube id #{url_id} not match #{src_id}" unless url_id == src_id
      popup.element(:class, 'mfp-close').click
    end

    assert_empty failure
  end

  def test_testimonials_page
    goto_alumni_reviews
    @browser.link(:text, 'testimonials page').click

    title = 'How do families use NCSA? | 400+ NCSA reviews'
    assert_equal title, @browser.title, 'Incorrect page title'

    DailyMonitor.subfooter.scroll.to; sleep 0.5

    failure = []

    @viewports.each do |size|
      open_eyes("TS-262 Test Testimonials Page - #{size.keys[0]}", size)

      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      @eyes.screenshot "Testimonials page #{size.keys[0]} view"

      result = @eyes.action.close(false)
      msg = "Testimonials page #{size.keys[0]} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_meet_more_members
    goto_alumni_reviews

    section = @browser.element(:class, 'node-title-meet-the-former-college-players--coaches-ready-to-help-you')
    button = section.element(:class, 'button--new-orange')
    url = button.attribute('href')

    resp = DailyMonitor.get_url_response(url)

    failure = []
    failure << "Playlist url gives #{resp}" unless resp.eql? 200
    failure << "Not a playlist redir url #{url}" unless url.include? 'playlist?list'
    assert_empty failure
  end
end
