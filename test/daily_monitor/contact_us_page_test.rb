# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-170
# UI Test: Daily Monitor - Contact Us Pages
# Verify That All Left Nav Links are Present and Working
class ContactUsPagesMonitorTest < Minitest::Test
  def setup
    config = YAML.load_file('old_config/config.yml')
    @contact_us = config['pages']['contact_us_page']
    @viewports = [
      { ipad: config['viewport']['ipad'] },
      { iphone: config['viewport']['iphone'] },
      { desktop: config['viewport']['desktop'] }
    ]
    @eyes = Applitool.new 'Content'
    @ui = UI.new 'browserstack', 'chrome'
    @browser = @ui.driver
    UIActions.setup(@browser)

    @pages = { 'About Us': 'About NCSA Next College Student Athlete',
               'What We Do': 'What We Do',
               'How We Do It': 'What to Expect with NCSA',
               'What Does NCSA Cost?': 'How much does NCSA Cost',
               'Products': 'NCSA Product',
               'Getting Started': '3 Easy Steps to Get Started with NCSA',
               'Our Mission': 'Our Mission',
               'Our People': 'Meet the NCSA Team',
               'Partners': 'NCSA Partners',
               'Press & Media': 'Press and Media',
               'Careers': 'NCSA Careers',
               'Contact Us': 'Contact Us' }
  end

  def teardown
    @browser.quit
  end

  def test_contact_us_page
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-170 Test Contact Us Page', width, height
      @browser.get @contact_us
      assert @browser.title.match(/Contact Us/), @browser.title

      # verify about us nav bar and its buttons
      assert @browser.find_element(:id, 'block-menu-block-19--2').displayed?, 'Side nav-bar not found'

      failure = []
      @pages.each do |link_text, _title|
        failure << "#{button} button not found" unless @browser.find_element(:link_text, link_text).enabled?
      end
      assert_empty failure

      #scroll to bottom for bottom icons to load
      @browser.find_elements(:class, 'container').last.location_once_scrolled_into_view; sleep 0.5

      # Make sure subfooter has correct phone number for different viewports
      subfooter = UIActions.get_subfooter
      UIActions.check_subfooter_msg(subfooter, size.keys[0].to_s)

      # Take snapshot events page with applitool eyes
      @eyes.screenshot "Contact Us page #{size.keys} view"
      result = @eyes.action.close(false)
      failure << "Contact Us page #{size.keys} - #{result.mismatches} mismatches found" unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_nav_bar_buttons_redir
    failure = []
    @pages.each do |link_text, expect_title|
      @browser.get @contact_us
      @browser.find_element(:link_text, link_text).click; sleep 1
      real_title = @browser.title

      failure << "#{link_text} page title: #{real_title} vs #{expect_title}" unless real_title.match expect_title
    end
    assert_empty failure
  end
end
