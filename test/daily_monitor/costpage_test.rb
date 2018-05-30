# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-119
# UI Test: Daily Monitor - Cost Page
class CostPageMonitorTest < VisualCommon
  def setup
    super
  end

  def teardown
    super
  end

  def check_and_remove_chatra
    begin
      chatra = @browser.element(:id, 'chatra')
      hide = "arguments[0].style.visibility='hidden'"
      @browser.execute_script(hide, chatra)
    rescue
      puts '[WARNING] Chatra not found...'
    end
  end

  def check_prices_buttons
    table = @browser.table(:id, 'pricing-table')
    row = table.row(:class, 'prices')
    buttons = row.elements(:class, 'button')

    failure = []
    buttons.each do |button|
      unless button.enabled?
        failure << "#{button.attribute_value('class')} not clickable"
        next
      end

      url = button.attribute_value('href')
      expected = 'http://www.ncsasports.org/Schedule-Your-NCSA-Recruiting-Evaluation'

      unless url == expected
        failure << "#{button.attribute_value('class')} has incorrect url"
        next
      end

      resp = DailyMonitor.get_url_response(url)

      if resp.is_a? Integer
        failure << "#{url} gives #{resp}" unless resp.eql? 200
      else
        failure << resp
      end
    end

    assert_empty failure
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

  def check_main_nav
    main_nav = @browser.element(:id, 'main-nav')

    failure = []

    [
      'Recruiting Guides',
      'Pick Your Sport',
      'Our Results',
      'Blog',
      'About NCSA',
      'Join'
    ].each do |link_text|
      main_option = main_nav.link(:text, link_text)

      response = check_option_response(main_option)
      failure << response unless response.nil?

      unless link_text == 'Blog'
        main_option.hover

        sub_menu = main_option.parent.element(:class, 'menu')
        sub_list = sub_menu.elements(:tag_name, 'a')

        sub_list.each do |option|
          response = check_option_response(option)
          failure << response unless response.nil?
        end
      end
    end

    assert_empty failure
  end

  def test_cost_page
    DailyMonitor.goto_page('cost_page')

    title = 'How much does NCSA Cost | NCSA Membership Levels'
    assert_equal title, @browser.title, 'Incorrect page title'

    check_main_nav
    check_prices_buttons
  end

  def test_costpage_visual
    DailyMonitor.goto_page('cost_page')

    check_and_remove_chatra
    DailyMonitor.subfooter.scroll.to; sleep 0.5

    failure = []

    @viewports.each do |size|
      open_eyes("TS-119 Test Cost Page - #{size.keys[0]}", size)

      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      @eyes.screenshot "Cost page #{size.keys[0]} view"

      unless size.keys.to_s =~ /desktop/
        DailyMonitor.hamburger_menu.click
        @eyes.screenshot "#{size.keys} view with hamburger menu open"
        DailyMonitor.hamburger_menu.click
      end

      result = @eyes.action.close(false)
      msg = "Cost page #{size.keys[0]} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end
end
