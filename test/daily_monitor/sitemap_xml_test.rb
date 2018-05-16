# encoding: utf-8
require_relative '../test_helper'

# TS-124
# UI Test: Sitemap.xml - Weekly Task
class SiteMapXMLTest < VisualCommon
  def setup
    super
  end

  def teardown
    super
  end

  def test_sitemap_xml
    DailyMonitor.goto_page('site_map')
    refute_empty @browser.html, 'Sitemap page source is empty'

    # list = @browser.find_elements(:tag_name, 'a'); list.pop
    # links = []
    # list.each do |e|
    #   links << e.attribute('href')
    # end
    # refute_empty links, 'Cannot find any URL on sitemap'

    # links.each do |url|
    #   begin
    #     resp = RestClient::Request.execute(method: :get, url: url, timeout: 10)
    #   rescue => e
    #     status_report << "#{url} gives error #{e}"; next
    #   end

    #   status_report << "#{url} gives #{resp.code}" if (300 .. 399).include? resp.code.to_i
    #   failure << "#{url} gives #{resp.code}" if (400 .. 599).include? resp.code.to_i
    # end

    # pp status_report unless status_report.empty?
    # assert_empty failure
  end
end
