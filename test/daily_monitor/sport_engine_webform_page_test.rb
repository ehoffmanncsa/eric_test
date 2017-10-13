# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-167
# UI Test: Daily Monitor - Sport Engine Branded Webform Page
class SportEngineWebFormPageMonitorTest < Minitest::Test
  def setup
    config = YAML.load_file('config/config.yml')
    @sport_engine = config['pages']['sport_engine_webform']
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

  def test_sport_engine_page
    @viewports.each do |size|
      width = size.values[0]['width']
      height = size.values[0]['height']

      @eyes.open @browser, 'TS-167 Test Sport Engine Webform Page', width, height
      @browser.get @sport_engine
      assert @browser.title.match(/Signup for NCSA Team Edition/), @browser.title

      # check for no index, no follow
      failure = []
      %w(noindex nofollow).each do |tag|
        failure << "Can't find tag #{tag}" unless @browser.page_source.include? tag
      end
      assert_empty failure

      # make sure no breadcrums and header nav bar
      assert !(@browser.page_source.include? 'breadcrumb'), 'Found bread crums where it should not'
      assert !(@browser.page_source.include? 'block-menu-menu-team-edition-top-nav'), 'Found header bar where it should not'

      #scroll down to trigger teaser image loading first
      @browser.find_elements(:class, 'content').each do |element|
        element.location_once_scrolled_into_view; sleep 0.5
      end

      # Take snapshot events page with applitool eyes
      @eyes.screenshot "Sport Engine page #{size.keys} view"
      result = @eyes.action.close(false)
      assert_equal 0, result.mismatches, "Sport Engine page #{size.keys} - #{result.mismatches} mismatches found"
    end
  end
end
