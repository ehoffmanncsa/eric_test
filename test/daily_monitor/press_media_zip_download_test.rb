# encoding: utf-8
require_relative '../test_helper'
require 'mechanize'
require 'zip'

# Daily Mornitor: TS-186
# UI Test: Daily Monitor - Press/Media ZIP Download Links Don't 404
class PressMediaZipDownloadTest < Minitest::Test
  def setup
    config = YAML.load_file('config/config.yml')
    @press_media = config['pages']['press_media_page']

    File.expand_path('downloads/', __FILE__)

    @agent = Mechanize.new
    @browser = (RemoteUI.new 'chrome').driver
  end

  def teardown
    FileUtils.rm_rf(Dir.glob('downloads'))
    @browser.quit
  end

  def test_download_zip_file
    @browser.get @press_media
    assert @browser.title.match(/Press and Media/), @browser.title

    download_link = @browser.find_element(:link_text, 'download our Brand Guidelines').attribute('href')
    file_name = "media-#{Random.rand(99_999)}.zip" 
    @agent.get(download_link).save("downloads/#{file_name}")

    # make sure zip file not empty
    refute_empty "downloads/#{file_name}", 'Brand Guidelines zip file is empty'

    # make sure each file in zip file not empty
    failure = []
    Zip::File.open("downloads/#{file_name}") do |zip_file|
      zip_file.each do |entry|
        failure << "#{entry.name} is empty" if entry.get_input_stream.read.empty?
      end
    end

    assert_empty failure
  end

  def test_download_pdf_files
    failure = []
    @browser.get @press_media
    assert @browser.title.match(/Press and Media/), @browser.title

    # make sure all downloaded pdf files not empty
    ['NCSA Fact Sheet', 'NCSA History'].each do |link_text|
      download_link = @browser.find_element(:link_text, link_text).attribute('href')
      file_name = "media-#{Random.rand(99_999)}.pdf" 
      @agent.get(download_link).save("downloads/#{file_name}")

      failure << "#{link_text} file is empty" if File.open("downloads/#{file_name}").read.empty?
    end

    assert_empty failure
  end
end
