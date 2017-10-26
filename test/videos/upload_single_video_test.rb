# encoding: utf-8
require_relative '../test_helper'
require 'securerandom'

# TS-5: Video regression
# UI Test: Upload a single video
class UploadSingleVideoTest < Minitest::Test
  def setup
    @ui = LocalUI.new(true)
    @browser = @ui.driver

    begin
      resp_code, resp_body, @username = RecruitAPI.new('freshman').ppost
      unless resp_code.eql? 200
        puts "POST new recuite to API gives #{resp_code}"
        @browser.quit; exit
      end
    rescue => e
      puts e; @browser.quit; exit
    end

    @client_id = resp_body['client_id']
    @recruit_email = "#{@username}@ncsasports.org"

    begin
      POSSetup.new.buy_package(@recruit_email, @username, 'elite')
    rescue => e
      puts e; @browser.quit; exit
    end
  end

  def teardown
    @browser.quit
  end

  def test_upload_single_video
    # upload video, also check for the form and buttons in the form
    @ui.user_login(@username)
    @browser.find_element(:id, 'profile_summary_button').click

    @browser.find_element(:class, 'subheader').find_element(:id, 'edit_video_link').click

    @browser.find_element(:class, 'js-upload-options').find_element(:class, 'upload-options-text').click
    assert @browser.find_element(:id, 'profile-video-upload').displayed?, 'Cannot find Video Upload Session'

    session = @browser.find_element(:class, 'action-buttons')
    assert session.find_element(:class, 'button--cancel').enabled?, 'Upload Session Cancel button not found'
    assert session.find_element(:class, 'button--primary').enabled?, 'Upload Session Upload button not found'

    @browser.find_element(:id, 'uploaded_video_as_is').find_elements(:tag_name, 'option')[1].click
    @browser.find_element(:id, 'uploaded_video_position').send_keys SecureRandom.hex(4)
    @browser.find_element(:id, 'uploaded_video_jersey_number').send_keys SecureRandom.hex(4)
    @browser.find_element(:id, 'uploaded_video_jersey_color').send_keys SecureRandom.hex(4)

    path = File.absolute_path('test/videos/sample.mp4')
    @browser.find_element(:id, 'profile-video-upload-file-input').send_keys path
    @browser.find_element(:class, 'action-buttons').find_element(:class, 'button--primary').click; sleep 1

    check_video_uploaded
    send_to_video_team
    impersonate
    check_sent_video
  end

  def check_video_uploaded
    @ui.wait(30) { @browser.find_element(:class, 'js-video-files-container').displayed? }
    assert @browser.find_element(:class, 'progress').displayed?, 'Cannot find progress bar'

    container = @browser.find_element(:class, 'js-video-files-container')
    list = container.find_element(:class, 'compilation-list')
    str = list.find_element(:class, 'compilation-list-item').text.split('-')
    date = str[0..2].join('-')
    file_name = str.last

    assert_equal date, Time.now.strftime('%Y-%m-%d'), 'Date is not today'
    assert_equal file_name, 'sample.mp4', 'Find unexpected file name'
  end

  def send_to_video_team
    section = @browser.find_element(:class, 'js-video-files-container')
    section.find_element(:class, 'button--primary').click
    assert @browser.find_element(:class, 'button--primary').enabled?, 'Send video modal Send button disabled'
    assert @browser.find_element(:class, 'button--cancel').enabled?, 'Send video modal Cancel button disabled'

    @browser.find_element(:class, 'button--primary').click; sleep 2
  end

  def impersonate
    @ui.fasttrack_login
    @browser.get 'https://qa.ncsasports.org/fasttrack/client/Search.do'

    @ui.wait.until { @browser.find_element(:id, 'content').displayed? }
    @browser.find_element(:name, 'emailAddress').send_keys @recruit_email
    @browser.find_element(:name, 'button').click
    @browser.manage.timeouts.implicit_wait = 10

    table = @browser.find_element(:class, 'breakdowndatatable')
    column = table.find_elements(:tag_name, 'td')[1]
    column.find_element(:tag_name, 'button').click; sleep 1

    # open tracking note
    @browser.get "https://qa.ncsasports.org/clientrms/profile/recruiting_profile/#{@client_id}/admin"
    side_bar = @browser.find_elements(:class, 'side-bar')[1]
    nav_bar = side_bar.find_element(:class, 'm-nav-vert')
    nav_bar.find_elements(:tag_name, 'li')[1].click
  end

  def check_sent_video
    failure = []

    # should be the first row in tracking message table
    table = @browser.find_element(:class, 'tn-table')
    row = table.find_element(:tag_name, 'tbody').find_elements(:tag_name, 'tr').first

    # check type
    type = row.find_elements(:tag_name, 'td')[0].text
    failure << "Type is not Video Received .. #{type}" unless type =~ /Video Received/

    # check date
    date = row.find_elements(:tag_name, 'td')[1].text.split(' ')[0]
    failure << 'Date is not today' unless date.eql? Time.now.strftime('%m/%d/%Y')

    # check message
    data = row.find_elements(:tag_name, 'td')[3].find_element(:class, 'show_tn')
    data_content = data.attribute('data-content')
    failure << "Incorrect file name #{data_content}" unless data_content.include? 'sample.mp4'

    assert_empty failure
  end
end