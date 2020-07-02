# encoding: utf-8
require_relative '../test_helper'

# TS-5: Video regression
# UI Test: Upload a single video
class UploadSingleVideo < Common
  def setup
    super
    email = 'ncsa.automation+e6cc@gmail.com'
    C3PO.setup(@browser)
    UIActions.user_login(email, 'ncsa1333')
    C3PO.goto_video
  end

  def teardown
    super
  end

   def test_upload_single_video

  # upload video, also check for the form and buttons in the form

    @browser.element(:id, 'profile_summary_button').click

    @browser.element(:class, 'subheader').element(:id, 'edit_video_link').click

    @browser.element(:class, 'js-upload-options').element(:class, 'upload-options-text').click
    assert @browser.element(:id, 'profile-video-upload').present?, 'Cannot find Video Upload Session'

    session = @browser.element(:class, 'action-buttons')
    assert session.element(:class, 'button--cancel').enabled?, 'Upload Session Cancel button not found'
    assert session.element(:class, 'button--primary').enabled?, 'Upload Session Upload button not found'

    @browser.element(:id, 'uploaded_video_as_is').elements(:tag_name, 'option')[1].click
    @browser.element(:id, 'uploaded_video_position').send_keys SecureRandom.hex(4)
    @browser.element(:id, 'uploaded_video_jersey_number').send_keys SecureRandom.hex(4)
    @browser.element(:id, 'uploaded_video_jersey_color').send_keys SecureRandom.hex(4)

    path = File.absolute_path('test/videos/sample.mp4')
    @browser.element(:id, 'profile-video-upload-file-input').send_keys path
    @browser.element(:class, 'action-buttons').element(:class, 'button--primary').click; sleep 2

    check_video_uploaded
    send_to_video_team
    impersonate
    check_sent_video
  end

  def check_video_uploaded
    assert @browser.element(:class, 'progress').present?, 'Cannot find progress bar'

    container = @browser.element(:class, 'js-video-files-container')
    list = container.element(:class, 'compilation-list')
    str = list.element(:class, 'compilation-list-item').text.split('-')
    date = str[0..2].join('-')
    file_name = str.last


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

    @browser.element(:name, 'emailAddress').send_keys 'ncsa.automation+e6cc@gmail.com'
    @browser.element(:name, 'button').click

    table = @browser.element(:class, 'breakdowndatatable')
    column = table.elements(:tag_name, 'td')[1]
    column.element(:tag_name, 'button').click; sleep 2

    # open tracking note
    @browser.window(:index, 1).use
    @browser.link(:text, 'Tracking Notes').click
  end

  def check_sent_video
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
    failure << "Incorrect file name #{data_content}" unless data_content.include? 'sample.mp4'

    assert_empty failure
  end
end
