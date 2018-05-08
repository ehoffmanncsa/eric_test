# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-170
# UI Test: Daily Monitor - Contact Us Pages
# Verify That All Left Nav Links are Present and Working
class ContactUsPagesMonitorTest < VisualCommon
  def setup
    super
    @contact_us = Default.static_info['pages']['contact_us_page']
    DailyMonitor.setup(@browser)

    @pages = {
      'About Us' => 'About NCSA Next College Student Athlete',
      'What We Do' => 'What We Do | The NCSA Experience',
      'How We Do It' => 'What to Expect with NCSA',
      'What Does NCSA Cost?' => 'How much does NCSA Cost | NCSA Membership Levels',
      'Products' => 'NCSA Product | The Collegiate Athletic Recruiting Network',
      'Getting Started' => '3 Easy Steps to Get Started with NCSA',
      'Our Mission' => 'Our Mission | NCSA is the trusted source in recruiting',
      'Our People' => 'Meet the NCSA Team | The NCSA Difference',
      'Partners' => '120+ companies partner with NCSA | NCSA Partners',
      'Press & Media' => 'Press and Media',
      'Careers' => 'NCSA Careers | Open Opportunities with NCSA',
      'Contact Us' => 'Contact Us | NCSA Address, Phone Number and Email'
    }
  end

  def teardown
    super
  end

  def test_contact_us_page
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser.driver, 'TS-170 Test Contact Us Page', width, height

      @browser.goto @contact_us
      msg = "Browser title: #{@browser.title} is not as expected: #{@pages['Contact Us']}"
      assert_equal @pages['Contact Us'], @browser.title, msg

      # verify about us nav bar and its buttons
      assert @browser.element(:id, 'block-menu-block-19--2').present?, 'Side nav-bar not found'

      failure = []
      @pages.each do |link_text, _title|
        failure << "#{button} button not found" unless @browser.link(:text, link_text).enabled?
      end
      assert_empty failure

      # check footer
      DailyMonitor.subfooter.scroll.to; sleep 0.5
      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      # Take snapshot events page with applitool eyes
      @eyes.screenshot "Contact Us page #{size.keys} view"
      result = @eyes.action.close(false)
      msg = "Contact Us page #{size.keys} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_nav_bar_buttons_redir
    failure = []
    @pages.each do |link_text, expect_title|
      @browser.goto @contact_us

      menu_block = @browser.div(:id, 'block-menu-block-19--2')
      menu_block.link(:text, link_text).click; sleep 1
      real_title = @browser.title
      msg = "#{link_text} page title: #{real_title} V.S. #{expect_title}"
      failure << msg unless real_title.eql? expect_title
    end
    assert_empty failure
  end
end
