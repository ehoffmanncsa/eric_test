# encoding: utf-8
require_relative '../test_helper'
require 'net/http'

# Daily Mornitor: TS-262
# UI Test: Reviews Page - Alumni Reviews
class AlumniReviewsTest < Minitest::Test
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

  def goto_alumni_reviews
    @browser.get @review_page
    nav_bar = @browser.find_element(:id, 'block-menu-block-25--2')
    menu = nav_bar.find_element(:class, 'menu')
    menu.find_element(:class, 'menu-mlid-6232').click

    str = "Meet NCSA’s team of 600+ former college and pro athletes"
    msg = "Browser title: #{@browser.title} is not as expected: #{str}"
    assert_equal str, @browser.title, msg

    # scroll down to trigger image loading first
    @browser.find_elements(:class, 'container').last.location_once_scrolled_into_view
    sleep 0.5
  end

  def scroll_to_last_quote
    section = @browser.find_element(:class, 'node-title-reviews--meet-our-experts-on-page-copy')
    field = section.find_element(:class, 'row').find_element(:class, 'field-name-body')
    field.find_elements(:tag_name, 'blockquote').last.location_once_scrolled_into_view
    sleep 0.5
  end

  def test_alumni_reviews_page
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-262 Test Alumni Reviews Page', width, height
      goto_alumni_reviews

      # check footer
      subfooter = UIActions.get_subfooter
      UIActions.check_subfooter_msg(subfooter, size.keys[0].to_s)

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
    scroll_to_last_quote

    section = @browser.find_element(:class, 'node-title-meet-the-former-college-players--coaches-ready-to-help-you')
    field = section.find_element(:class, 'row').find_element(:class, 'field-name-field-dices')
    videos = field.find_elements(:class, 'field-name-field-image')

    # go though each video, check if the url gives 200
    # if 200 click on it, make sure there is popup and popup url has matching video id
    # if not dont bother
    bad_response = [], bad_popup = [], bad_id = []
    videos.each do |vid|
      url = vid.find_element(:tag_name, 'a').attribute('href')
      url_id = url.split('=')[1]
    
      uri = URI(url)
      res = Net::HTTP.get_response(uri)
      code = res.code.to_i
      bad_response << "Video id #{url_id} gives #{res.code}" unless code.eql? 200

      if code.eql? 200
        vid.click; sleep 0.5
        popup = @browser.find_element(:class, 'mfp-content')
        iframe = popup.find_element(:class, 'mfp-iframe')
        bad_popup << "Video id #{url_id} no popup" unless iframe.displayed?

        if iframe.displayed?
          src = iframe.attribute('src')
          src_id = src.split('/').last.split('?')[0]
          bad_id << "youtube id #{url_id} not match #{src_id}" unless url_id == src_id
          popup.find_element(:class, 'mfp-close').click
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

      @eyes.open @browser, 'TS-262 Test Testimonials Page', width, height
      goto_alumni_reviews
      scroll_to_last_quote
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

  def test_meet_more_members
    goto_alumni_reviews
    scroll_to_last_quote

    section = @browser.find_element(:class, 'node-title-meet-the-former-college-players--coaches-ready-to-help-you')
    button = section.find_element(:class, 'button--new-orange')
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