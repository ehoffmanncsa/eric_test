# encoding: utf-8

require_relative '../test_helper'
require 'eyes_selenium'

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
    @eyes = Applitool.new config['applitool']['apikey'], 'Content'
    @browser = (RemoteUI.new 'chrome').driver
  end

  def teardown
    @browser.quit
  end

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

    if size == 'desktop'
      check_top_nav_and_sub_menu
    else
      check_hamburger_and_sub_menu
    end

    # Verify breadcrum and Coach Login link exisit and clickable on this page
    assert @browser.find_element(:class, 'breadcrumb').displayed?
    assert @browser.find_element(:link_text, 'Coach Login').enabled?
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
    ['TEAM EDITION', 'WHY NCSA?', 'RESOURCE CENTER', 'GET STARTED'].each do |option|
      assert @browser.find_element(:link_text, option).enabled?, "Team option #{option} not found"
    end

    # Check burger sub-menu
    @browser.find_element(:link_text, 'TEAM EDITION').click
    ['Team Edition', 'Coach Features', 'Player Features', 'Pricing', "Who's Using It"].each do |option|
      assert @browser.find_element(:link_text, option).enabled?, "#{option} feature not found"
    end

    @browser.find_element(:class, 'fa-bars').click # close it after use
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

  def test_TED_menu_headers
    @browser.get @ted_page
    check_top_nav_and_sub_menu
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

  # Verify feature pages
  def test_coach_features_page
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-122 Test TED Coach Features Page', width, height
      goto_feature_page(size.keys[0].to_s, 'Coach Features')
    
      # Make sure we are on the right page
      assert @browser.title.match(/Team Edition Features for Club Coaches/), @browser.title

      page_spot_check(size.keys[0].to_s)
      assert (@browser.page_source.include? 'block-menu-block-8--2'), 'Side-nav bar not found'

      @eyes.screenshot "Coach Features page #{size.keys} view"
      @eyes.action.close(false)
    end
  end

  def test_player_features_page
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-122 Test TED Player Features Page', width, height
      goto_feature_page(size.keys[0].to_s, 'Player Features')

      # Make sure we are on the right page
      assert @browser.title.match(/Team Edition Features for Athletes/), @browser.title

      page_spot_check(size.keys[0].to_s)
      assert (@browser.page_source.include? 'block-menu-block-8--2'), 'Side-nav bar not found'

      @eyes.screenshot "Player Features page #{size.keys} view"
      @eyes.action.close(false)
    end
  end

  def test_pricing_page
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-122 Test TED Pricing Page', width, height
      goto_feature_page(size.keys[0].to_s, 'Pricing')

      # Make sure we are on the right page
      assert @browser.title.match(/Team Edition Pricing/), @browser.title

      page_spot_check(size.keys[0].to_s)
      assert (@browser.page_source.include? 'block-menu-block-8--2'), 'Side-nav bar not found'

      @eyes.screenshot "Pricing page #{size.keys} view"
      @eyes.action.close(false)
    end
  end

  def test_who_using_it_page
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, "TS-122 Test TED Who's Using It Page", width, height
      goto_feature_page(size.keys[0].to_s, "Who's Using It")

      # Make sure we are on the right page
      assert @browser.title.match(/Team Edition Reviews/), @browser.title

      page_spot_check(size.keys[0].to_s)
      assert (@browser.page_source.include? 'block-menu-block-8--2'), 'Side-nav bar not found'

      @eyes.screenshot "Who's Using It page #{size.keys} view"
      @eyes.action.close(false)
    end
  end

  # Verify pages from headers redir
  def test_why_NCSA_page
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-122 Test TED Why NCSA Page', width, height
      goto_feature_page(size.keys[0].to_s, 'WHY NCSA?')

      # Make sure we are on the right page
      assert @browser.title.match(/About NCSA Team Edition/), @browser.title

      page_spot_check(size.keys[0].to_s)
      assert !(@browser.page_source.include? 'block-menu-block-8--2'), 'Side-nav bar found where it should not'

      @eyes.screenshot "Why NCSA page #{size.keys} view"
      @eyes.action.close(false)
    end
  end

  def test_resource_center_page
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-122 Test TED Resource Center Page', width, height
      goto_feature_page(size.keys[0].to_s, 'RESOURCE CENTER')

      # Make sure we are on the right page
      assert @browser.title.match(/Recruiting Resources for Club & High School Coaches/), @browser.title

      page_spot_check(size.keys[0].to_s)
      assert !(@browser.page_source.include? 'block-menu-block-8--2'), 'Side-nav bar found where it should not'

      @eyes.screenshot "Resource Center page #{size.keys} view"
      @eyes.action.close(false)
    end
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
