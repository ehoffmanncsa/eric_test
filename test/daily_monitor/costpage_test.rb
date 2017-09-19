# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-119
# UI Test: Daily Monitor - Cost Page
class CostPageMonitorTest < Minitest::Test
  def setup
    config = YAML.load_file('config/config.yml')
    @viewports = [
      { ipad: config['viewport']['ipad'] },
      { iphone: config['viewport']['iphone'] },
      { desktop: config['viewport']['desktop'] }
    ]
    @costpage = config['pages']['cost_page']
    @eyes = Applitool.new config['applitool']['apikey'], 'Content'
    @browser = (RemoteUI.new 'chrome').driver
  end

  def teardown
    @browser.quit
  end

  # Start a applitool eye test session
  # Within the session loop through different viewport size
  # and navigate to cost page, verify page title
  def test_costpage_views
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-119 Test Cost Page', width, height
      @browser.get @costpage
      assert @browser.title.match(/How much does NCSA Cost/), @browser.title

      # Take snapshot cost page with applitool eyes
      @eyes.screenshot "Cost page #{size.keys} view"
      @eyes.action.close(false)
    end
  end

  # Verify hamburger menu and phone icon enable for iphone and ipad view
  def test_views_with_hamburger_menu_open
    @viewports.each do |size|
      next if size.keys.to_s =~ /desktop/
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-119 Test Cost Page with Hamburger Menu Open', width, height
      @browser.get @costpage

      # Verify iphone and hamburger exists
      assert @browser.find_element(:id, 'block-block-62').enabled?, 'Tablet and Hamburger not found'
      # Click on hamburger menu to open it
      @browser.find_element(:class, 'fa-bars').click
      
      @eyes.screenshot "#{size.keys} view with hamburger menu open"
      @eyes.action.close(false)
    end
  end

  def test_parents_athletes_start_here
    @viewports.each do |size|
      next if size.keys.to_s =~ /desktop/
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-119 Test Parents and Athletes Start Here Buttons', width, height

      %w[Parents Athletes].each do |button|
        @browser.get @costpage
        assert @browser.find_element(link_text: "#{button} Start Here").enabled?, "#{button} Start Here button not found"

        @browser.find_element(link_text: "#{button} Start Here").click
        assert @browser.title.match(/Athletic Recruiting/), @browser.title

        @eyes.screenshot "#{button} recruiting form #{size.keys} view"
      end

      @eyes.action.close(false)
    end
  end

  def test_hamburger_menu_options_and_redirs
    @viewports.each do |size|
      next if size.keys.to_s =~ /desktop/
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-119 Test Hamburger Menu and Redirs', width, height

      ['Athlete Log In', 'Coach Log In', 'H.S. Coach',
       'Parents Start Here', 'Athletes Start Here'].each do |link_text|
        @browser.get @costpage
        @browser.find_element(:class, 'fa-bars').click
        button = @browser.find_element(link_text: link_text)

        case link_text
          when 'Athlete Log In'
            button.click
            assert @browser.title.match(/Student-Athlete Sign In/), @browser.title
            username_input = @browser.find_element(:id, 'user_account_login')
            assert username_input.displayed?, 'Username textbox not found'

            @eyes.check_ignore "#{link_text} login #{size.keys} view", username_input
          when 'Coach Log In'
            button.click
            assert @browser.title.match(/College Coach Login/), @browser.title
            assert @browser.find_element(link_text: 'Get Started Now').enabled?, 'Get Started button not found'

            @eyes.action.check_window "hamburger menu redir to #{link_text} #{size.keys} view"
          when 'H.S. Coach'
            button.click
            assert @browser.title.match(/High School Coach Login/), @browser.title
            assert @browser.find_element(link_text: 'Learn More').enabled?, 'Learn More button not found'
            assert @browser.find_element(link_text: 'Get Started Now').enabled?, 'Get Started button not found'

            @eyes.check_ignore "#{link_text} login #{size.keys} view", @browser.find_element(:class, 'banner_bg')
          when 'Parents Start Here'
            @browser.find_element(:class, 'm-nav-start-link--parent').click
            assert @browser.title.match(/NCSA Athletic Recruiting/), @browser.title

          when 'Athletes Start Here'
            @browser.find_element(:class, 'm-nav-start-link--athlete').click
            assert @browser.title.match(/NCSA Athletic Recruiting/), @browser.title
        end
      end

      @eyes.action.close(false)
    end
  end

  def test_www_athlete_login_redir
    @browser.get @costpage
    login_button = @browser.find_element(class: 'menu-item-has-children')
    assert login_button.enabled?, 'Athlete Login button not found'

    @browser.action.move_to(login_button).perform
    ['Athlete Profile Login', 'College Coach Login', 'HS Coach Login'].each do |button|
      assert @browser.find_element(link_text: button).enabled?, "#{button} option not found"
    end

    @browser.find_element(link_text: 'Athlete Profile Login').click
    assert @browser.title.match(/Student-Athlete Sign In/), @browser.title
  end
end
