# encoding: utf-8
require_relative '../test_helper'

def goto_feature_page(size, feature)
  @browser.get @ted_page

  if size == 'desktop'
    @browser.action.move_to(@browser.find_element(:link_text, 'TEAM EDITION')).perform
    @browser.find_element(:link_text, feature).click
  else
    @browser.find_element(:class, 'fa-bars').click; sleep 0.3
    @browser.find_element(:link_text, 'TEAM EDITION').click; sleep 0.3
    @browser.find_element(:link_text, feature).click
  end

  @browser
end

def page_spot_check(size)
  # Find the free demo button 
  assert @browser.find_element(:link_text, 'Request a Free Demo').enabled?, 'Demo button not found'

  # check top-nav, sub menu and coach login button
  if size == 'desktop'
    check_top_nav_and_sub_menu
    assert @browser.find_element(:link_text, 'Coach Login').enabled?
  else
    check_hamburger_and_sub_menu
  end

  # Verify breadcrum is visible on this page
  assert @browser.find_element(:class, 'breadcrumb').displayed?
end

def check_top_nav_and_sub_menu
  # Make sure top nav bar exist
  assert @browser.find_element(:id, 'block-menu-menu-team-edition-top-nav').displayed?, 'Top nav bar not found'

  # Make sure header options enable
  ['TEAM EDITION', 'WHY NCSA?', 'RESOURCE CENTER', 'GET STARTED'].each do |header|
    assert @browser.find_element(:link_text, header).enabled?, "Menu header option #{header} not found"
  end

  # Check sub menu
  @browser.action.move_to(@browser.find_element(:link_text, 'TEAM EDITION')).perform
  ['Team Edition', 'Coach Features', 'Player Features', 'Pricing', "Who's Using It"].each do |option|
    assert @browser.find_element(:link_text, option).enabled?, "#{option} feature not found"
  end
end

def check_hamburger_and_sub_menu
  # Make sure block contains tablet and burger exists
  assert @browser.find_element(:id, 'block-block-63').enabled?, 'Tablet and Hamburger not found'

  # Check options under burger
  @browser.find_element(:class, 'fa-bars').click; sleep 0.3
  ['Coach Login', 'TEAM EDITION', 'WHY NCSA?', 'RESOURCE CENTER', 'GET STARTED'].each do |option|
    assert @browser.find_element(:link_text, option).enabled?, "Team option #{option} not found"
  end

  # Check burger sub-menu
  @browser.find_element(:link_text, 'TEAM EDITION').click
  ['Team Edition', 'Coach Features', 'Player Features', 'Pricing', "Who's Using It"].each do |option|
    assert @browser.find_element(:link_text, option).enabled?, "#{option} feature not found"
  end

  @browser.find_element(:class, 'fa-bars').click # close it after use
end

# Daily Mornitor: TS-122
# UI Test: Daily Monitor - TED Page
class TEDPageMonitorTest < Minitest::Test
  def setup
    config = YAML.load_file('config/config.yml')
    @ted_page = config['pages']['ted_page']
    @demo_req_page = config['pages']['free_demo_request']
    @viewports = [
      { ipad: config['viewport']['ipad'] },
      { iphone: config['viewport']['iphone'] },
      { desktop: config['viewport']['desktop'] }
    ]
    @eyes = Applitool.new 'Content'
    @browser = (RemoteUI.new 'chrome').driver
  end

  def teardown
    @browser.quit
  end

  # Start a applitool eye test session
  # Within the session loop through different viewport size
  # and navigate to TED page, verify page title and take page snapshot for comparison
  def test_ted_page_views
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-122 Test TED Page', width, height
      @browser.get @ted_page
      assert @browser.title.match(/Club Coach College Recruiting Software/), @browser.title

      view = size.keys[0].to_s
      case view
        when 'desktop'
          # check coach login button, top-nav, menu headers
          assert @browser.find_element(:link_text, 'Coach Login').enabled?, 'Coach Login not found'
          assert @browser.find_element(:id, 'block-menu-menu-team-edition-top-nav').displayed?, 'Top nav bar not found'
          ['TEAM EDITION', 'WHY NCSA?', 'RESOURCE CENTER', 'GET STARTED'].each do |header|
            assert @browser.find_element(:link_text, header).enabled?, "Menu header option #{header} not found"
          end

        when 'iphone' then assert @browser.find_element(:id, 'block-block-63').enabled?, 'Tablet and Hamburger not found'
        when 'ipad' then assert @browser.find_element(:id, 'block-block-63').enabled?, 'Tablet and Hamburger not found'
      end

      # Take snapshot TED page with applitool eyes
      @eyes.screenshot "TED page #{size.keys} view"
      @eyes.action.close(false)
    end
  end

  def test_TED_menu_headers
    @browser.get @ted_page
    check_top_nav_and_sub_menu
  end

  # Verify Free Demo button, redir and page spotcheck
  def test_request_demo_button_redir
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-122 Test TED Request Demo Redir', width, height
      @browser.get @ted_page
      assert @browser.find_element(:partial_link_text, 'Request a Demo').enabled?, 'Demo button not found'

      @browser.find_element(:partial_link_text, 'Request a Demo').click
      assert @browser.title.match(/Signup for NCSA Team Edition/), @browser.title

      @eyes.screenshot "Get Started form #{size.keys} view"
      @eyes.action.close(false)
    end
  end

  # Verify hamburger menu and phone icon enable for iphone and ipad view
  def test_views_with_hamburger_menu_open
    @viewports.each do |size|
      next if size.keys.to_s =~ /desktop/
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-122 Test TED Page with Hamburger Menu Open', width, height
      @browser.get @ted_page

      # Click on hamburger menu to open it
      @browser.find_element(:class, 'fa-bars').click; sleep 0.3
      @browser.find_element(:link_text, 'TEAM EDITION').click

      @eyes.screenshot "#{size.keys} view with hamburger menu open"
      @eyes.action.close(false)
    end
  end

  # Verify coach login page redir and page spotcheck
  def test_coach_login_page
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-122 Test TED Coach Login Page', width, height
      @browser.get @ted_page

      view = size.keys[0].to_s
      case view
        when 'desktop' then @browser.find_element(:link_text, 'Coach Login').click
        else
          @browser.find_element(:class, 'fa-bars').click
          @browser.find_element(:link_text, 'Coach Login').click
      end

      assert @browser.title.match(/Recruiting Management System/), @browser.title

      @eyes.screenshot "Coach login page #{size.keys} view"
      @eyes.action.close(false)
    end
  end

  # Verify feature pages redir and content spotcheck
  def test_feature_pages
    failure = []
    pages = { 'Coach Features': 'Team Edition Features for Club Coaches',
              'Player Features': 'Team Edition Features for Athletes',
              'Pricing': 'Team Edition Pricing',
              "Who's Using It": 'Team Edition Reviews' }

    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-122 Test TED Feature Pages', width, height
      pages.each do |page, expect_title|
        goto_feature_page(size.keys[0].to_s, page)
        real_title = @browser.title

        # Make sure we are on the right page
        failure << "#{size.keys} - #{real_title} v.s. #{expect_title}" unless real_title.match expect_title
        failure << "#{size.keys} - Side-nav bar not found" unless @browser.page_source.include? 'block-menu-block-8--2'

        @eyes.screenshot "#{page} page #{size.keys} view"
        page_spot_check(size.keys[0].to_s)
      end

      @eyes.action.close(false)
    end

    assert_empty failure
  end

  # Verify pages from headers redir and content spotcheck
  def test_why_NCSA_page
    failure = []
    pages = { 'WHY NCSA?': 'About NCSA Team Edition',
              'RESOURCE CENTER': 'Recruiting Resources for Club & High School Coaches' }

    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-122 Test TED Pages from Header Menu', width, height
      pages.each do |page, expect_title|
        goto_feature_page(size.keys[0].to_s, page)
        real_title = @browser.title

        # Make sure we are on the right page and spot check
        failure << "#{size.keys} - #{real_title} v.s. #{expect_title}" unless real_title.match expect_title
        failure << "#{size.keys} - Side-nav bar found where it should not"  if @browser.page_source.include? 'block-menu-block-8--2'

        @eyes.screenshot "#{page} page #{size.keys} view"
        page_spot_check(size.keys[0].to_s)
      end

      @eyes.action.close(false)
    end

    assert_empty failure
  end

  def test_get_started_page
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      # Make sure we are on the right page
      @browser.manage.window.resize_to(width, height)
      goto_feature_page(size.keys[0].to_s, 'GET STARTED')
      assert @browser.title.match(/Signup for NCSA Team Edition/)
    end
  end
end
