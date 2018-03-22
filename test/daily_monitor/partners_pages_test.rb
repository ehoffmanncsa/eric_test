# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-169
# UI Test: Daily Monitor - Partners Pages
class PartnersPagesMonitorTest < Minitest::Test
  def setup
    config = YAML.load_file('config/config.yml')
    @partners_page = config['pages']['partners_page']
    @viewports = [
      { ipad: config['viewport']['ipad'] },
      { iphone: config['viewport']['iphone'] },
      { desktop: config['viewport']['desktop'] }
    ]
    @eyes = Applitool.new 'Content'
    @ui = UI.new 'browserstack', 'chrome'
    @browser = @ui.driver
    UIActions.setup(@browser)
  end

  def teardown
    begin @browser.quit; rescue; end
  end

  # spotcheck partners page in different views
  # all logos links give 200, breadcrumbs show up and side-nav bar buttons redir correctly
  def test_partners_page_spotcheck
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @browser.manage.window.resize_to(width, height)
      @browser.get @partners_page

      # make sure breadcrums present
      failure << "#{size.keys} Breab crumbs not found" unless @browser.find_element(:class, 'breadcrumb').displayed?

      # checking side-nav bar and it's buttons
      failure << "#{size.keys} Side-nav bar not found" unless @browser.find_element(:class, 'right-sidebar').displayed?

      ['Partners', 'All Partners', 'Apply for Partnership'].each do |link_text|
        button = @browser.find_element(:link_text, link_text)
        failure << "#{size.keys} #{link_text} button not found" unless button.enabled?
      end
    end

    assert_empty failure
  end

  def test_partner_page_sidebar_buttons_redir
    pages = { Partners: 'NCSA Partners',
              All_Partners: 'View all NCSA partners',
              Apply_for_Partnership: 'NCSA Partnership Program' }

    @browser.get @partners_page

    failure = []
    pages.each do |page, expect_title|
      href = @browser.find_element(:link_text, page.to_s.gsub('_', ' ')).attribute('href')
      @browser.get href
      real_title = @browser.title

      failure << "#{page} - #{real_title}" unless real_title.match expect_title
    end

    assert_empty failure
  end

  def test_logos_on_partners_page
    @browser.get @partners_page
    logos = @browser.find_elements(:class, 'field-name-field-image')

    # check url response
    # 200 is good so do nothing and go to next url, 
    # 300 .. 399 and any error should be reported, 
    # 400+ should fail the test
    status_report = []; hrefs = []; failure = []
    logos.each { |logo| hrefs << logo.find_element(:tag_name, 'a').attribute('href') }

    hrefs.each do |url|
      begin
        resp = RestClient::Request.execute(method: :get, url: url, timeout: 10)
      rescue => e
        status_report << "#{url} gives error #{e}"; next
      end

      status_report << "#{url} gives #{resp.code}" if (300 .. 399).include? resp.code.to_i
      failure << "#{url} gives #{resp.code}" if (400 .. 599).include? resp.code.to_i
    end

    pp status_report unless status_report.empty?
    assert_empty failure

    # make sure no duplicate urls
    dupe = hrefs.select{|e| hrefs.count(e) > 1 }
    assert_empty dupe
  end

  def test_partners_page_views
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-169 Test Partners Page', width, height
      @browser.get @partners_page
      assert @browser.title.match(/NCSA Partners/), @browser.title

      @browser.find_elements(:class, 'container').last.location_once_scrolled_into_view; sleep 0.5

      subfooter = UIActions.get_subfooter
      UIActions.check_subfooter_msg(subfooter, size.keys[0].to_s)

      # Take snapshot events page with applitool eyes
      @eyes.check_ignore "Partners page #{size.keys} view", [@browser.find_element(:class, 'field-name-field-node-bucket')]
      result = @eyes.action.close(false)
      failure << "Partners page #{size.keys} - #{result.mismatches} mismatches found" unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_parents_athletes_start_here_buttons
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-169 Test Parents/Athletes Start Here Buttons', width, height

      %w[Parents Athletes].each do |button|
        @browser.get @partners_page

        case size.keys[0].to_s
          when 'desktop'
            block = @browser.find_element(:id, 'block-block-71--2')
            assert block.find_element(link_text: "#{button} Start Here").enabled?, "#{button} Start Here not found"

            block.find_element(link_text: "#{button} Start Here").click
            assert @browser.title.match(/Athletic Recruiting/), @browser.title
            assert (@browser.current_url.include? 'NW_Partners'), 'URL not including NW_Partners'
          else
            block = @browser.find_element(:id, 'block-menu-menu-mobile-cta-buttons')
            assert block.find_element(link_text: "#{button} Start Here").enabled?, "#{button} Start Here not found"

            block.find_element(link_text: "#{button} Start Here").click
            assert @browser.title.match(/Athletic Recruiting/), @browser.title
            assert (@browser.current_url.include? 'WWW_Mobile'), 'URL not including WWW_Mobile'
        end

        subfooter = UIActions.get_subfooter
        UIActions.check_subfooter_msg(subfooter, size.keys[0].to_s)

        @eyes.screenshot "#{button} recruiting form #{size.keys} view"
      end

      result = @eyes.action.close(false)
      failure << "Athlete/Parent Start Here #{size.keys} - #{result.mismatches} mismatches found" unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  # combining testing for all partners page views and redirecting back to partners page
  def test_all_partners_page
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @browser.manage.window.resize_to(width, height)
      @browser.get @partners_page
      @browser.find_element(:link_text, 'All Partners Page').click
      assert @browser.title.match(/View all NCSA partners/), @browser.title

      # scroll through each row for all logo to load
      @browser.find_element(:class, 'views-view-grid').find_elements(:class, 'row').each do |row|
        row.location_once_scrolled_into_view; sleep 0.2
      end

      @browser.find_elements(:class, 'container').last.location_once_scrolled_into_view; sleep 0.2

      # check returning to partners page
      button = @browser.find_element(:link_text, 'Partners')
      assert button.enabled?, 'Partners button not found'
      @browser.get button.attribute('href')
      assert @browser.title.match(/NCSA Partners/), @browser.title
    end
  end

  def test_logos_on_all_partners_page
    @browser.get @partners_page
    @browser.find_element(:link_text, 'All Partners Page').click

    # check url response
    # 200 is good, 300 .. 399 should be reported, 400+ should fail the test
    status_report = []; hrefs = []; failure = []
    @browser.find_element(:class, 'views-view-grid').find_elements(:class, 'row').each do |row|
      row.find_elements(:class, 'views-field-field-partner-image').each do |logo|
        hrefs << logo.find_element(:tag_name, 'a').attribute('href')
      end
    end

    hrefs.each do |url|
      begin
        resp = RestClient::Request.execute(method: :get, url: url, timeout: 10)
      rescue => e
        status_report << "#{url} gives error #{e}"; next
      end

      status_report << "#{url} gives #{resp.code}" if (300 .. 399).include? resp.code.to_i
      failure << "#{url} gives #{resp.code}" if (400 .. 599).include? resp.code.to_i
    end

    pp status_report unless status_report.empty?
    assert_empty failure
  end

  def test_views_with_hamburger_menu_open
    failure = []
    @viewports.each do |size|
      next if size.keys.to_s =~ /desktop/
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-169 Test Partners Page with Hamburger Menu Open', width, height
      @browser.get @partners_page 

      # Verify iphone and hamburger exists
      assert @browser.find_element(:id, 'block-block-62').enabled?

      # Click on hamburger menu to open it
      @browser.find_element(:class, 'fa-bars').click
      @browser.find_elements(:class, 'container').last.location_once_scrolled_into_view; sleep 0.5

      subfooter = UIActions.get_subfooter
      UIActions.check_subfooter_msg(subfooter, size.keys[0].to_s)

      @eyes.check_ignore "#{size.keys} view with hamburger menu open", [@browser.find_element(:class, 'field-name-field-node-bucket')]
      result = @eyes.action.close(false)
      failure << "Partners page #{size.keys} with burger - #{result.mismatches} mismatches found" unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_apply_partnership_page
    failure = []
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-169 Test Apply Partnership Page', width, height
      @browser.get @partners_page
      button = @browser.find_element(:link_text, 'Apply for Partnership')
      assert button.enabled?, 'Apply for Partnership button not found'

      @browser.get button.attribute('href')
      assert @browser.title.match(/NCSA Partnership Program/), @browser.title

      # verify mailto link
      email_address = @browser.find_element(:link_text, 'partnerships@ncsasports.org')
      assert email_address.enabled?, 'Cannot find mailto email address'
      assert (email_address.attribute('href').include? 'mailto:'), 'Email href not including mailto'

      subfooter = UIActions.get_subfooter
      UIActions.check_subfooter_msg(subfooter, size.keys[0].to_s)

      @eyes.screenshot "Apply Partnership page #{size.keys} view"
      result = @eyes.action.close(false)
      failure << "Apply Partnership page #{size.keys} - #{result.mismatches} mismatches found" unless result.mismatches.eql? 0
    end

    assert_empty failure
  end
end
