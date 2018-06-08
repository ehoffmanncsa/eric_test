# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-122
# UI Test: Daily Monitor - TED Page
class TEDPageMonitorTest < VisualCommon
  def setup
    super
  end

  def teardown
    super
  end

  def goto_feature_page(size, feature)
    DailyMonitor.goto_page('ted_www_page')

    if size == 'desktop'
      @browser.link(:text, 'Team Edition').hover
      @browser.link(:text, feature).click
    else
      @browser.element(:class, 'fa-bars').click
      @browser.link(:text, 'Team Edition').click
      @browser.link(:text, feature).click
    end
  end

  def page_spot_check(size)
    # check top-nav, sub menu and coach login button
    if size == 'desktop'
      check_top_nav_and_sub_menu
      assert @browser.link(:text, 'Coach Login').enabled?
    else
      check_hamburger_and_sub_menu
    end

    # Verify breadcrum is visible on this page
    assert @browser.element(:class, 'breadcrumb').present?
  end

  def check_team_edition_sub_menu
    result = []

    @browser.link(:text, 'Team Edition').hover

    ['Team Edition', 'Coach Features', 'Player Features', 'Pricing', "Who's Using It"].each do |option|
      element = @browser.link(:text, option)

      unless element.enabled?
        result << "#{option} feature not found"
        next
      end

      resp = DailyMonitor.get_url_response(element.attribute_value('href'))

      if resp.is_a? Integer
        result << "#{option} gives #{resp}" unless resp.eql? 200
      else
        result << resp
      end
    end

    result
  end

  def check_top_nav_and_sub_menu
    # Make sure top nav bar exist
    assert @browser.element(:id, 'block-menu-menu-team-edition-top-nav').present?, 'Top nav bar not found'

    # Make sure header options enable
    failure = []

    ['Team Edition', 'Why NCSA?', 'Resource Center', 'Get Started'].each do |header|
      element = @browser.link(:text, header)

      unless element.enabled?
        failure << "Menu header option #{header} not found"
        next
      end

      resp = DailyMonitor.get_url_response(element.attribute_value('href'))

      if resp.is_a? Integer
        failure << "#{header} gives #{resp}" unless resp.eql? 200
      else
        failure << resp
      end
    end

    # Check Team Edition sub menu
    unless @browser.link(:text, 'Team Edition').enabled?
      result = check_team_edition_sub_menu
      failure << result unless result.empty?
    end

    assert_empty failure
  end

  def check_hamburger_and_sub_menu
    DailyMonitor.hamburger_menu.click

    failure = []

    ['Coach Login', 'Team Edition', 'Why NCSA?', 'Resource Center', 'Get Started'].each do |option|
      element = @browser.link(:text, option)

      unless element.enabled?
        failure << "Hamburger menu option #{option} not found"
        next
      end

      resp = DailyMonitor.get_url_response(element.attribute_value('href'))

      if resp.is_a? Integer
        failure << "#{resp} - #{leaf.text}" unless resp.eql? 200
      else
        failure << resp
      end
    end

    # Check Team Edition sub menu
    unless @browser.link(:text, 'Team Edition').enabled?
      result = check_team_edition_sub_menu
      failure << result unless result.empty?
    end

    assert_empty failure

    DailyMonitor.hamburger_menu.click
  end

  def test_ted_page_visual
    DailyMonitor.goto_page('ted_www_page')

    title = 'NCSA Team Edition | Club Coach College Recruiting Software'
    assert_equal title, @browser.title, 'Incorrect page title'

    failure = []

    @viewports.each do |size|
      open_eyes("TS-122 Test TED Page - #{size.keys[0]}", size)

      @eyes.screenshot "TED page #{size.keys[0]} view"

      result = @eyes.action.close(false)
      msg = "TED page #{size.keys[0]} view - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_related_page_spotcheck
    failure = []

    related_pages = {
      'Coach Features' => 'NCSA Team Edition Features for Club Coaches',
      'Player Features' => 'NCSA Team Edition Features for Athletes',
      'Pricing' => 'NCSA Team Edition Pricing | Cost of Team Edition',
      "Who's Using It" => 'NCSA Team Edition Partners | Team Edition Reviews',
      'Why NCSA?' => 'About NCSA Team Edition | NCSA for Club Coaches',
      'Resource Center' => 'Recruiting Resources for Club & High School Coaches',
      'Get Started' => 'Signup for NCSA Team Edition'
    }

    @viewports.each do |size|
      DailyMonitor.resize_browser(size)

      related_pages.each do |page, expect_title|
        goto_feature_page(size.keys[0].to_s, page)

        page_spot_check(size.keys[0].to_s)

        unless @browser.title == expect_title
          failure << "#{page} - Incorrect page title"
          next
        end

        unless @browser.div(:id, 'block-menu-block-8--2')
          failure << "#{page} #{size.keys[0]} view - Side-nav bar not found"
          next
        end
      end
    end

    assert_empty failure
  end

  def test_request_demo_button
    DailyMonitor.goto_page('ted_www_page')

    @browser.element(:visible_text, 'Request a Demo Here »').click

    title = 'Signup for NCSA Team Edition'
    assert_equal title, @browser.title, 'Incorrect page title'
  end
end
