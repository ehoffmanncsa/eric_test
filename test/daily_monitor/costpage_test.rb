# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-119
# UI Test: Daily Monitor - Cost Page
class CostPageMonitorTest < VisualCommon
  def setup
    super
    @costpage = Default.static_info['pages']['cost_page']
    DailyMonitor.setup(@browser)
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

  # Start a applitool eye test session
  # Within the session loop through different viewport size
  # and navigate to cost page, verify page title
  def test_costpage_views
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser.driver, 'TS-119 Test Cost Page', width, height

      @browser.goto @costpage
      expect = 'How much does NCSA Cost | NCSA Membership Levels'
      msg = "Browser title: #{@browser.title} is not as expected: #{expect}"
      assert_equal expect, @browser.title, msg

      # check footer
      DailyMonitor.subfooter.scroll.to; sleep 0.5
      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      # Take snapshot cost page with applitool eyes
      @eyes.screenshot "Cost page #{size.keys} view"
      result = @eyes.action.close(false)
      msg = "Cost page #{size.keys} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  # Verify hamburger menu and phone icon enable for iphone and ipad view
  def test_views_with_hamburger_menu_open
    failure = []
    @viewports.each do |size|
      next if size.keys.to_s =~ /desktop/
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser.driver, 'TS-119 Test Cost Page with Hamburger Menu Open', width, height

      @browser.goto @costpage

      # Verify iphone and hamburger exists
      assert @browser.element(:id, 'block-block-62').present?, 'Tablet and Hamburger not found'

      # Click on hamburger menu to open it
      @browser.element(:class, 'fa-bars').click

      check_and_remove_chatra

      # check footer
      DailyMonitor.subfooter.scroll.to; sleep 0.5
      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      @eyes.screenshot "#{size.keys} view with hamburger menu open"
      result = @eyes.action.close(false)
      msg = "Cost page #{size.keys} view with burger - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_parents_athletes_start_here
    failure = []
    @viewports.each do |size|
      next if size.keys.to_s =~ /desktop/
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser.driver, 'TS-119 Test Parents and Athletes Start Here Buttons', width, height

      %w[Parents Athletes].each do |button|
        @browser.goto @costpage

        block = @browser.div(:id, 'block-menu-menu-mobile-cta-buttons')
        assert block.link(text: "#{button} Start Here").enabled?, "#{button} Start Here button not found"

        block.link(text: "#{button} Start Here").click
        assert @browser.title.match(/Athletic Recruiting/), @browser.title

        # check footer
        DailyMonitor.subfooter.scroll.to; sleep 0.5
        DailyMonitor.check_subfooter_msg(size.keys[0].to_s)
        @eyes.screenshot "#{button} recruiting form #{size.keys} view"
      end

      result = @eyes.action.close(false)
      msg = "Athlete/Parent Start Here #{size.keys} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_hamburger_menu_options_and_redirs
    failure = []
    @viewports.each do |size|
      next if size.keys.to_s =~ /desktop/
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser.driver, 'TS-119 Test Hamburger Menu and Redirs', width, height

      ['Athlete Log In', 'Coach Log In', 'HS/Club Coach',
       'Parents Start Here', 'Athletes Start Here'].each do |link_text|
        @browser.goto @costpage

        @browser.element(:class, 'fa-bars').click
        button = @browser.link(text: link_text)

        case link_text
          when 'Athlete Log In'
            button.click
            expect = 'Student-Athlete Sign In | NCSA Client Recruiting Management System'
            msg = "Browser title: #{@browser.title} is not as expected: #{expect}"
            assert_equal expect, @browser.title, msg

            @eyes.screenshot "#{link_text} login #{size.keys} view"
          when 'Coach Log In'
            button.click
            expect = 'College Coach Login | NCSA Coach Recruiting Management System'
            msg = "Browser title: #{@browser.title} is not as expected: #{expect}"
            assert_equal expect, @browser.title, msg

            assert @browser.link(text: 'Get Started Now').present?, 'Get Started button not found'

            @eyes.screenshot "Hamburger menu redir to #{link_text} #{size.keys} view"
          when 'HS/Club Coach'
            button.click
            expect = 'Team Edition | Recruiting Management System'
            msg = "Browser title: #{@browser.title} is not as expected: #{expect}"
            assert_equal expect, @browser.title, msg

            assert @browser.link(text: 'Learn More').enabled?, 'Learn More button not found'
            assert @browser.link(text: 'Get Started Now').enabled?, 'Get Started button not found'

            video_banner = @browser.wd.find_element(:class, 'video-banner__container')
            @eyes.check_ignore "#{link_text} login #{size.keys} view", [video_banner]
          when 'Parents Start Here'
            msg = 'Parent Start Here button not found in hamburger'
            assert @browser.element(:class, 'm-nav-start-link--parent').enabled?, msg

          when 'Athletes Start Here'
            msg = 'Athlete Start Here not found in hamburger'
            assert @browser.element(:class, 'm-nav-start-link--athlete').enabled?, msg
        end
      end

      result = @eyes.action.close(false)
      msg = "Burger redir pages #{size.keys} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_www_athlete_login_redir
    @browser.goto @costpage
    login_button = @browser.element(class: 'menu-item-has-children')
    assert login_button.enabled?, 'Athlete Login button not found'

    login_button.hover
    ['Athlete Profile Login', 'College Coach Login', 'HS/Club Coach Login'].each do |button|
      assert @browser.link(text: button).enabled?, "#{button} option not found"
    end

    @browser.link(text: 'Athlete Profile Login').click
    expect = 'Student-Athlete Sign In | NCSA Client Recruiting Management System'
    msg = "Browser title: #{@browser.title} is not as expected: #{expect}"
    assert_equal expect, @browser.title, msg
  end
end
