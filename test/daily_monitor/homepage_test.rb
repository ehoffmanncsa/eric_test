# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-118
# UI Test: Daily Monitor - Homepage
class HomePageMonitorTest < Minitest::Test
  def setup
    config = YAML.load_file('config/config.yml')
    @viewports = [
      { ipad: config['viewport']['ipad'] },
      { iphone: config['viewport']['iphone'] },
      { desktop: config['viewport']['desktop'] }
    ]
    @homepage = config['pages']['home_page']
    @eyes = Applitool.new 'Content'
    @ui = UI.new 'browserstack', 'chrome'
    @browser = @ui.driver
    UIActions.setup(@browser)
  end

  def teardown
    @browser.quit
  end

  # Start a applitool eye test session
  # Within the session loop through different viewport size
  # and navigate to WWW site homepage, verify page title
  # using remote UI - BrowserStack
  def test_homepage
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      # Open eyes and go to page
      @eyes.open @browser, 'TS-118 Test HomePage', width, height
      @browser.get @homepage
      assert @browser.title.match(/Get Recruited/), @browser.title

      #scroll down to trigger teaser image loading first
      @browser.find_elements(:class, 'teaser-image').each do |element|
        element.location_once_scrolled_into_view; sleep 0.5
      end
      @browser.find_elements(:class, 'container').last.location_once_scrolled_into_view; sleep 0.5

      subfooter = UIActions.get_subfooter
      UIActions.check_subfooter_msg(subfooter, size.keys[0].to_s)

      # Snapshot Homepage with applitool 
      @eyes.screenshot "Home page #{size.keys} view"
      # prevent eyes from closing before done looping
      result = @eyes.action.close(false)
      failure << "Home page #{size.keys} view - #{result.mismatches} mismatches found" unless result.mismatches.eql? 0    
    end

    assert_empty failure
  end

  # Verify hamburger menu and phone icon enable for iphone and ipad view
  def test_homepage_view_with_hamburger_menu
    failure = []
    @viewports.each do |size|
      next if size.keys.to_s =~ /desktop/
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-118 Test Homepage with Hamburger Menu Open', width, height
      @browser.get @homepage
      # Verify iphone and hamburger exists
      assert @browser.find_element(:id, 'block-block-62').enabled?, 'Tablet and Hamburger not found'

      # Click on hamburger menu to open it
      @browser.find_element(:class, 'fa-bars').click
      #scroll down to trigger teaser image loading first
      @browser.find_elements(:class, 'teaser-image').each do |element|
        element.location_once_scrolled_into_view; sleep 0.5
      end

      @browser.find_elements(:class, 'container').last.location_once_scrolled_into_view; sleep 0.5
      subfooter = UIActions.get_subfooter
      UIActions.check_subfooter_msg(subfooter, size.keys[0].to_s)
      @eyes.screenshot "#{size.keys} view with hamburger menu open"
      result = @eyes.action.close(false)
      failure << "Home page #{size.keys} view with burger - #{result.mismatches} mismatches found" unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  # Verify the Start Here buttons are enabled
  # and redirect correctly by verifying redirected page title
  def test_parents_athletes_start_here_buttons
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, "TS-118 Test Parents/Athletes Start Here Button", width, height

      %w[Parents Athletes].each do |button|
        @browser.get @homepage
        assert @browser.find_element(link_text: "#{button} Start Here").enabled?, "#{button} Start Here not found" 

        @browser.find_element(link_text: "#{button} Start Here").click
        assert @browser.title.match(/Athletic Recruiting/), @browser.title

        @eyes.screenshot "#{button} recruiting form #{size.keys} view"        
      end

      result = @eyes.action.close(false)
      failure << "Athlete/Parent Start Here #{size.keys} - #{result.mismatches} mismatches found" unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_coaches_start_here
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-118 Test Coaches Start Here Button', width, height
      @browser.get @homepage
      button = @browser.find_element(link_text: "Coaches Start Here")
      assert button.enabled?, 'Coaches Start Here not found'

      button.location_once_scrolled_into_view if size.keys.to_s =~ /iphone/
      button.click
      assert @browser.title.match(/College Coach Login/), @browser.title
      assert @browser.find_element(link_text: 'Get Started Now').enabled?, 'Get Started button not found'

      # Take page snapshot but ignore the banner
      @eyes.check_ignore "Coaches login #{size.keys} view", [@browser.find_element(:class, 'banner')]
      result = @eyes.action.close(false)
      failure << "Coach login #{size.keys} view - #{result.mismatches} mismatches found" unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  # Verify Hamburger menu in ipad and iphone views
  # and its buttons redirect correctly
  def test_hamburger_menu_options_and_redirs
    failure = []
    @viewports.each do |size|
      next if size.keys.to_s =~ /desktop/
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-118 Test Hamburger Menu and Redirs', width, height

      ['Athlete Log In', 'Coach Log In', 'H.S. Coach',
       'Parents Start Here', 'Athletes Start Here'].each do |link_text|
        @browser.get @homepage
        @browser.find_element(:class, 'fa-bars').click

        begin
          retries ||= 0
          button = @browser.find_element(link_text: link_text)
          case link_text
            when 'Athlete Log In'
              button.click
              assert @browser.title.match(/Student-Athlete Sign In/), @browser.title
              username_input = @browser.find_element(:id, 'user_account_login')
              assert username_input.displayed?, 'Username textbox not found'

              # Ignore the username textbox because it has blinking cursor
              @eyes.check_ignore "#{link_text} login #{size.keys} view", [username_input]
            when 'Coach Log In'
              button.click
              assert @browser.title.match(/College Coach Login/), @browser.title
              assert @browser.find_element(link_text: 'Get Started Now').enabled?, 'Get Started button not found'

              @eyes.screenshot "#{size.keys} view - redir to #{link_text} from hamburger menu"
            when 'H.S. Coach'
              button.click
              assert @browser.title.match(/High School Coach Login/), @browser.title
              assert @browser.find_element(link_text: 'Learn More').enabled?, 'Learn More button not found'
              assert @browser.find_element(link_text: 'Get Started Now').enabled?, 'Get Started button not found'

              @eyes.check_ignore "#{link_text} login #{size.keys} view", [@browser.find_element(:class, 'banner_bg')]
            when 'Parents Start Here'
              @browser.find_element(:class, 'm-nav-start-link--parent').click
              assert @browser.title.match(/NCSA Athletic Recruiting/), @browser.title

            when 'Athletes Start Here'
              @browser.find_element(:class, 'm-nav-start-link--athlete').click
              assert @browser.title.match(/NCSA Athletic Recruiting/), @browser.title
          end
        rescue => e
          puts "Encounter error #{e} - at #{link_text}", 'Trying again....'
          retry if (retries += 1) < 3
        end
      end

      result = @eyes.action.close(false)
      failure << "Burger redir pages #{size.keys} - #{result.mismatches} mismatches found" unless result.mismatches.eql? 0
    end

    assert_empty failure
  end


  def test_athlete_login_redir
    @browser.get @homepage
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
