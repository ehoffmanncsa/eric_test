# encoding: utf-8
require_relative '../test_helper'
require 'mechanize'
require 'zip'

# Daily Mornitor: TS-186
# UI Test: Daily Monitor - Press/Media ZIP Download Links Don't 404
class PressMediaZipDownloadTest < VisualCommon
  def setup
    super

    File.expand_path('downloads/', __FILE__)
    @agent = Mechanize.new
  end

  def teardown
    FileUtils.rm_rf(Dir.glob('downloads'))

    super
  end

  def goto_press_media
    DailyMonitor.goto_page('press_media_page')

    title = 'Press and Media'
    assert_equal title, @browser.title, 'Incorrect page title'
  end

  def test_download_zip_file
    goto_press_media

    download_link = @browser.link(:text, 'download our Brand Guidelines').attribute('href')
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
    goto_press_media

    failure = []

    # make sure all downloaded pdf files not empty
    ['NCSA Fact Sheet', 'NCSA History'].each do |link_text|
      download_link = @browser.link(:text, link_text).attribute('href')
      file_name = "media-#{Random.rand(99_999)}.pdf"
      @agent.get(download_link).save("downloads/#{file_name}")

      failure << "#{link_text} file is empty" if File.open("downloads/#{file_name}").read.empty?
    end

    assert_empty failure
  end
end
