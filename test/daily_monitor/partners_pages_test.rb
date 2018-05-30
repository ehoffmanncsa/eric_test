# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-169
# UI Test: Daily Monitor - Partners Pages
class PartnersPagesMonitorTest < VisualCommon
  def setup
    super
  end

  def teardown
    super
  end

  # spotcheck partners page in different views
  # all logos links give 200, breadcrumbs show up and side-nav bar buttons redir correctly
  def test_partners_page_spotcheck
    DailyMonitor.goto_page('partners_page')

    title = '120+ companies partner with NCSA | NCSA Partners'
    assert_equal title, @browser.title, 'Incorrect page title'

    failure = []
    @viewports.each do |size|
      @browser.window.resize_to(DailyMonitor.width(size), DailyMonitor.height(size))

      # make sure breadcrums present
      failure << "#{size.keys[0]} Breab crumbs not found" unless @browser.element(:class, 'breadcrumb').present?

      # checking side-nav bar and it's buttons
      failure << "#{size.keys[0]} Side-nav bar not found" unless @browser.element(:class, 'right-sidebar').present?

      ['Partners', 'All Partners', 'Apply for Partnership'].each do |link_text|
        button = @browser.link(:text, link_text)
        failure << "#{size.keys[0]} #{link_text} button not found" unless button.enabled?
      end
    end

    assert_empty failure
  end

  def test_partner_page_sidebar_buttons_redir
    pages = {
      'Partners' => 'NCSA Partners',
      'All Partners' => 'View all NCSA partners',
      'Apply for Partnership' => 'NCSA Partnership Program'
    }

    DailyMonitor.goto_page('partners_page')

    failure = []
    pages.each do |link_text, expect_title|
      href = @browser.link(:text, link_text).attribute('href')

      @browser.goto href
      real_title = @browser.title

      msg = "#{link_text} title #{real_title} ... not as expected #{expect_title}"
      failure << msg unless real_title.match expect_title
    end

    assert_empty failure
  end

  def test_logos_on_partners_page
    DailyMonitor.goto_page('partners_page')

    logos = @browser.elements(:class, 'field-name-field-image')

    # check url response
    # 200 is good so do nothing and go to next url,
    # 300 .. 399 and any error should be reported,
    # 400+ should fail the test
    status_report = []; hrefs = []; failure = []
    logos.each { |logo| hrefs << logo.element(:tag_name, 'a').attribute('href') }

    hrefs.each do |url|
      resp = DailyMonitor.get_url_response(url)

      if resp.is_a? Integer
        status_report << "#{url} gives #{resp.code}" if (300 .. 399).include? resp
        failure << "#{url} gives #{resp.code}" if (400 .. 599).include? resp
      else
        status_report << resp
      end
    end

    pp status_report unless status_report.empty?
    assert_empty failure

    # make sure no duplicate urls
    dupe_urls = hrefs.select { |e| hrefs.count(e) > 1 }
    assert_empty dupe_urls
  end

  def test_partners_page_visual
    DailyMonitor.goto_page('partners_page')
    DailyMonitor.subfooter.scroll.to; sleep 0.5

    failure = []

    @viewports.each do |size|
      open_eyes("TS-169 Test Partners Page - #{size.keys[0]}", size)

      #@browser.elements(:class, 'container').last.location_once_scrolled_into_view; sleep 0.5

      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      node = @browser.wd.find_element(:class, 'field-name-field-node-bucket')
      @eyes.check_ignore "Partners page #{size.keys} view", [node]

      unless size.keys.to_s =~ /desktop/
        DailyMonitor.hamburger_menu.click # open
        @eyes.check_ignore "#{size.keys[0]} view with hamburger menu open", [node]
        DailyMonitor.hamburger_menu.click # close
      end

      result = @eyes.action.close(false)
      msg = "Partners page #{size.keys[0]} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end

  def test_logos_on_all_partners_page
    DailyMonitor.goto_page('partners_page')
    @browser.link(:text, 'All Partners Page').click

    title = 'View all NCSA partners | 90+ strategic partners'
    assert_equal title, @browser.title, 'Incorrect page title'

    # check url response
    # 200 is good, 300 .. 399 should be reported, 400+ should fail the test
    status_report = []; hrefs = []; failure = []

    @browser.element(:class, 'views-view-grid').elements(:class, 'row').each do |row|
      row.elements(:class, 'views-field-field-partner-image').each do |logo|
        hrefs << logo.element(:tag_name, 'a').attribute('href')
      end
    end

    hrefs.each do |url|
      resp = DailyMonitor.get_url_response(url)

      if resp.is_a? Integer
        status_report << "#{url} gives #{resp.code}" if (300 .. 399).include? resp
        failure << "#{url} gives #{resp.code}" if (400 .. 599).include? resp
      else
        status_report << resp
      end
    end

    pp status_report unless status_report.empty?
    assert_empty failure
  end

  def test_apply_partnership_page
    DailyMonitor.goto_page('partners_page')
    @browser.link(:text, 'Apply for Partnership').click

    title = 'NCSA Partnership Program | Apply Now'
    assert_equal title, @browser.title, 'Incorrect page title'

    DailyMonitor.subfooter.scroll.to; sleep 0.5

    failure = []

    @viewports.each do |size|
      open_eyes("TS-169 Test Apply Partnership Page - #{size.keys[0]}", size)

      # verify mailto link
      email_address = @browser.links(:text, 'partnerships@ncsasports.org')
      assert email_address, 'Cannot find mailto email address'
      assert (email_address.attribute('href').include? 'mailto:'), 'Email href not including mailto'

      DailyMonitor.check_subfooter_msg(size.keys[0].to_s)

      @eyes.screenshot "Apply Partnership page #{size.keys[0]} view"

      result = @eyes.action.close(false)
      msg = "Apply Partnership page #{size.keys[0]} - #{result.mismatches} mismatches found"
      failure << msg unless result.mismatches.eql? 0
    end

    assert_empty failure
  end
end
