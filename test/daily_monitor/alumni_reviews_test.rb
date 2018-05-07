# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-262
# UI Test: Reviews Page - Alumni Reviews
class AlumniReviewsTest < VisualCommon
  def setup
    super
    @review_page = Default.static_info['pages']['review_page']
    DailyMonitor.setup(@browser)
  end

  def teardown
    super
  end

  def goto_alumni_reviews
    @browser.goto @review_page
    nav_bar = @browser.element(:id, 'block-menu-block-25--2')
    nav_bar.link(:text, 'Our Recruiting Coaches').click

    str = "Meet NCSA’s team of 600+ former college and pro athletes"
    msg = "Browser title: #{@browser.title} is not as expected: #{str}"
    assert_equal str, @browser.title, msg
  end

  def test_alumni_reviews_page
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser.driver, 'TS-262 Test Alumni Reviews Page', width, height
      goto_alumni_reviews

      # check footer
      DailyMonitor.subfooter.scroll.to; sleep 0.5
      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      # Take snapshot review page with applitool eyes
      @eyes.screenshot "Alumni Reviews #{size.keys} view"
      result = @eyes.action.close(false)
      msg = "Alumni Reviews #{size.keys} - #{result.mismatches} mismatches found"
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
    bad_response = [], bad_popup = [], bad_id = []
    videos.each do |vid|
      url = vid.element(:tag_name, 'a').attribute('href')
      url_id = url.split('=')[1]

      uri = URI(url)
      res = Net::HTTP.get_response(uri)
      code = res.code.to_i
      bad_response << "Video id #{url_id} gives #{res.code}" unless code.eql? 200

      if code.eql? 200
        vid.click
        popup = @browser.element(:class, 'mfp-content')
        iframe = popup.element(:class, 'mfp-iframe')
        bad_popup << "Video id #{url_id} no popup" unless iframe.present?

        if iframe.present?
          src = iframe.attribute('src')
          src_id = src.split('/').last.split('?')[0]
          bad_id << "youtube id #{url_id} not match #{src_id}" unless url_id == src_id
          popup.element(:class, 'mfp-close').click
        end
      end
    end

    failure = (bad_response + bad_popup + bad_id).flatten
    assert_empty failure
  end

  def test_testimonials_page
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser.driver, 'TS-262 Test Testimonials Page', width, height
      goto_alumni_reviews
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

  def test_meet_more_members
    goto_alumni_reviews

    section = @browser.element(:class, 'node-title-meet-the-former-college-players--coaches-ready-to-help-you')
    button = section.element(:class, 'button--new-orange')
    url = button.attribute('href')

    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    code = res.code.to_i

    failure = []
    failure << "Playlist url gives #{code}" unless code.eql? 200
    failure << "Not a playlist redir url #{url}" unless url.include? 'playlist?list'
    assert_empty failure
  end
end
