# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-120
# UI Test: Daily Monitor - Review Page
class ReviewPageMonitorTest < Minitest::Test
  def setup
    config = YAML.load_file('config/config.yml')
    @review_page = config['pages']['review_page']
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
  # and navigate to review page, verify page title
  def test_review_page_views
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-120 Test Review Page', width, height
      @browser.get @review_page
      assert @browser.title.match(/NCSA Reviews and Testimonials/), @browser.title

      #scroll down to trigger teaser image loading first
      @browser.find_elements(:class, 'teaser-image').each do |element|
        element.location_once_scrolled_into_view; sleep 0.5
      end
      @browser.find_elements(:class, 'container').last.location_once_scrolled_into_view; sleep 0.5

      # Take snapshot review page with applitool eyes
      @eyes.screenshot "Review page #{size.keys} view"
      @eyes.action.close(false)
    end
  end

  # Verify hamburger menu and phone icon enable for iphone and ipad view
  def test_views_with_hamburger_menu_open
    @viewports.each do |size|
      next if size.keys.to_s =~ /desktop/
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-120 Test Review Page with Hamburger Menu Open', width, height
      @browser.get @review_page
      # Verify iphone and hamburger exists
      assert @browser.find_element(:id, 'block-block-62').enabled?, 'Tablet and Hamburger not found'

      # Click on hamburger menu to open it
      @browser.find_element(:class, 'fa-bars').click
      #scroll down to trigger teaser image loading first
      @browser.find_elements(:class, 'teaser-image').each do |element|
        element.location_once_scrolled_into_view; sleep 0.5
      end

      @browser.find_elements(:class, 'container').last.location_once_scrolled_into_view; sleep 0.5

      @eyes.screenshot "#{size.keys} view with hamburger menu open"
      @eyes.action.close(false)
    end
  end

  def test_parents_athletes_start_here
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-120 Test Parents and Athletes Start Here Buttons', width, height

      %w[Parents Athletes].each do |button|
        @browser.get @review_page
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

      @eyes.open @browser, 'TS-120 Test Hamburger Menu Options and Redirs', width, height

      ['Athlete Log In', 'Coach Log In', 'H.S. Coach',
       'Parents Start Here', 'Athletes Start Here'].each do |link_text|
        @browser.get @review_page
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

            @eyes.screenshot "#{size.keys} view - redir to #{link_text} from hamburger menu"
          when 'H.S. Coach'
            button.click
            assert @browser.title.match(/High School Coach Login/), @browser.title
            assert @browser.find_element(link_text: 'Learn More').enabled?, 'Learn More button not found'
            assert @browser.find_element(link_text: 'Get Started Now').enabled?, 'Get Start button not found'

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
    @browser.get @review_page
    login_button = @browser.find_element(class: 'menu-item-has-children')
    assert login_button.enabled?, 'Login button not found'

    @browser.action.move_to(login_button).perform
    ['Athlete Profile Login', 'College Coach Login', 'HS Coach Login'].each do |button|
      assert @browser.find_element(link_text: button).enabled?, "#{button} option not found"
    end

    @browser.find_element(link_text: 'Athlete Profile Login').click
    assert @browser.title.match(/Student-Athlete Sign In/), @browser.title
  end
end
