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
    links = []
    list.each do |e|
      links << e.attribute('href')
    end
    
    refute_empty links, 'Cannot find any URL on sitemap'
  end
end
