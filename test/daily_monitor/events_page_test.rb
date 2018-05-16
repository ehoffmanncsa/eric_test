# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-121
# UI Test: Daily Monitor - Events Page
class EventsPageMonitorTest < VisualCommon
  def setup
    super
  end

  def teardown
    super
  end

  def check_option_response(option)
    failure = nil

    url = option.attribute_value('href')
    resp = DailyMonitor.get_url_response(url)

    if resp.is_a? Integer
      failure = "#{url} gives #{resp}" unless resp.eql? 200
    else
      failure = resp
    end

    failure
  end

  def test_right_sidebar_options
    DailyMonitor.goto_page('events_page')

    sidebar = @browser.div(:class, 'right-sidebar')
    block = sidebar.div(:class, 'holder').div(:id, 'block-menu-block-31--2')

    menu = block.element(:class, 'menu')

    failure = []

    menu.elements(:tag_name, 'a').each do |option|
      unless option.enabled?
        failure << "#{option.text} not clickable"
        next
      end

      response = check_option_response(option)
      failure << response unless response.nil?
    end

    assert_empty failure
  end

  def test_events_page_visual
    DailyMonitor.goto_page('events_page')
    DailyMonitor.subfooter.scroll.to; sleep 0.5

    failure = []

    @viewports.each do |size|
      open_eyes("TS-121 Test Events Page - #{size.keys[0]}", size)

      text = 'The Ins and Outs of Camps, Combines and Showcases'
      assert_equal text, @browser.title, 'Unexpected title'

      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      @eyes.screenshot "Events page #{size.keys[0]} view"

      unless size.keys.to_s =~ /desktop/
        DailyMonitor.hamburger_menu.click
        @eyes.screenshot "#{size.keys} view with hamburger menu open"
        DailyMonitor.hamburger_menu.click
      end

      result = @eyes.action.close(false)
      msg = "Events page #{size.keys[0]} view - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_pick_your_sport_redir
    DailyMonitor.goto_page('events_page')

    # Use football for this test case
    dropdown = @browser.select_list(name: 'jump')
    dropdown.select 'Football'
    assert_equal 'Football Camps', @browser.element(:tag_name, 'h1').text, 'Incorrect page header'

    # check footer
    DailyMonitor.check_subfooter_msg('desktop')

    events = @browser.elements(:class, 'img_left_half_teaser')
    refute_empty events, 'No events found on Football Events page'
  end
end
