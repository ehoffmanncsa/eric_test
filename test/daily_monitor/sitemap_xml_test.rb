# encoding: utf-8
require_relative '../test_helper'

# TS-124
# UI Test: Sitemap.xml - Weekly Task
class SiteMapXMLTest < Minitest::Test
  def setup
    config = YAML.load_file('config/config.yml')
    @site_map = config['pages']['site_map']

    @browser = (RemoteUI.new 'chrome').driver
  end

  def teardown
    @browser.quit
  end

  def test_sitemap_xml
    @browser.get @site_map
    assert @browser.title.match(/Sitemap/), @browser.title

    list = @browser.find_elements(:tag_name, 'a'); list.pop
    failure = []
    list.each do |e|
      link = e.attribute('href')
      status = Faraday.get(link).status
      failure << "#{link} gives #{status}" unless status.eql? 200
    end
    
    assert_empty failure
    assert list.length.eql? 969, "Found #{list.length} links"
  end
end
