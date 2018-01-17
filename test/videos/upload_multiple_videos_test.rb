# encoding: utf-8
require_relative '../test_helper'

# TS-6: Video regression
# UI Test: Upload a multiple videos
class UploadMultipleVideosTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @recruit_email = post_body[:recruit][:athlete_email]

    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@browser)

    POSSetup.buy_package(@recruit_email, 'champion')
  end

  def teardown
    @browser.close
  end

  def test_upload_multiple_videos
    # upload video, also check for the form and buttons in the form
    UIActions.user_login(@recruit_email)

    %w[avi mp4 mov].each do |extention|
      @browser.goto 'https://qa.ncsasports.org/clientrms/profile/video'
      @browser.element(:class, 'js-upload-options').element(:class, 'upload-options-text').click
      assert @browser.element(:id, 'profile-video-upload').visible?, 'Cannot find Video Upload Session'

      session = @browser.element(:class, 'action-buttons')
      assert session.element(:class, 'button--cancel').enabled?, 'Upload Session Cancel button not found'
      assert session.element(:class, 'button--primary').enabled?, 'Upload Session Upload button not found'

      @browser.element(:id, 'uploaded_video_as_is').elements(:tag_name, 'option')[1].click
      @browser.element(:id, 'uploaded_video_position').send_keys SecureRandom.hex(4)
      @browser.element(:id, 'uploaded_video_jersey_number').send_keys SecureRandom.hex(4)
      @browser.element(:id, 'uploaded_video_jersey_color').send_keys SecureRandom.hex(4)

      path = File.absolute_path("test/videos/sample.#{extention}")
      @browser.element(:id, 'profile-video-upload-file-input').send_keys path
      @browser.element(:class, 'action-buttons').element(:class, 'button--primary').click; sleep 2
    end

    check_videos_uploaded
    send_to_video_team
    impersonate
    check_sent_videos
  end

  def check_videos_uploaded
    assert @browser.element(:class, 'progress').visible?, 'Cannot find progress bar'

    failure = []; loaded_files = []
    container = @browser.element(:class, 'js-video-files-container')
    list = container.element(:class, 'compilation-list')

    # check date for each uploaded file
    list.elements(:class, 'compilation-list-item').each do |elem|
      str = elem.text.split('-')
      date = str[0..2].join('-')
      loaded_files << str.last
      failure << "#{date} is not today" unless date.eql? Time.now.strftime('%Y-%-m-%-d')
    end

    # check file name for each uploaded file
    org_files = %w[sample.avi sample.mp4 sample.mov]
    loaded_files.each { |file| failure << "File name #{file} is incorrect" unless org_files.include? file }

    assert_empty failure
  end

  def send_to_video_team
    section = @browser.element(:class, 'js-video-files-container')
    section.element(:class, 'button--primary').click
    assert @browser.element(:class, 'button--primary').enabled?, 'Send video modal Send button disabled'
    assert @browser.element(:class, 'button--cancel').enabled?, 'Send video modal Cancel button disabled'

    @browser.element(:class, 'button--primary').click; sleep 2
  end

  def impersonate
    UIActions.fasttrack_login
    @browser.goto 'https://qa.ncsasports.org/fasttrack/client/Search.do'

    @browser.element(:name, 'emailAddress').send_keys @recruit_email
    @browser.element(:name, 'button').click

    table = @browser.element(:class, 'breakdowndatatable')
    column = table.elements(:tag_name, 'td')[1]
    column.element(:tag_name, 'button').click; sleep 2

    # open tracking note
    @browser.window(:index, 1).use
    @browser.link(:text, 'Tracking Notes').click
  end

  def check_sent_videos
    failure = []

    # should be the first row in tracking message table
    table = @browser.element(:class, 'tn-table')
    row = table.element(:tag_name, 'tbody').elements(:tag_name, 'tr').first

    # check type
    type = row.elements(:tag_name, 'td')[0].text
    failure << "Type is not Video Received .. #{type}" unless type =~ /Video Received/

    # check date
    date = row.elements(:tag_name, 'td')[1].text.split(' ')[0]
    failure << 'Date is not today' unless date.eql? Time.now.strftime('%m/%d/%Y')

    # check message
    data = row.elements(:tag_name, 'td')[3].element(:class, 'show_tn')
    data_content = data.attribute('data-content')
    %w[avi mp4 mov].each do |extention|
      failure << "Incorrect file name #{data_content}" unless data_content.include? "sample.#{extention}"
    end

    assert_empty failure
  end
end
