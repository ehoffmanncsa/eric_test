# encoding: utf-8
require_relative '../../test/test_helper'

# This helper is to help in performing video related actions
class Video
  def initialize(username, email)
    @ui = LocalUI.new(true)
    @browser = @ui.driver

    @username = username
    @recruit_email = email
  end

  def teardown
    @browser.quit
  end

  def upload_video(path = 'test/videos/sample.mp4')
    path = File.absolute_path(path)
    @ui.user_login(@username)

    # Go to user profile and open upload section
    @browser.find_element(:id, 'profile_summary_button').click
    @browser.find_element(:class, 'subheader').find_element(:id, 'edit_video_link').click
    @browser.find_element(:class, 'js-upload-options').find_element(:class, 'upload-options-text').click

    # fill out the upload form
    @browser.find_element(:id, 'uploaded_video_as_is').find_elements(:tag_name, 'option')[1].click
    @browser.find_element(:id, 'uploaded_video_position').send_keys SecureRandom.hex(4)
    @browser.find_element(:id, 'uploaded_video_jersey_number').send_keys SecureRandom.hex(4)
    @browser.find_element(:id, 'uploaded_video_jersey_color').send_keys SecureRandom.hex(4)

    # send in file path and upload
    @browser.find_element(:id, 'profile-video-upload-file-input').send_keys path
    @browser.find_element(:class, 'action-buttons').find_element(:class, 'button--primary').click; sleep 1
  end


  def send_to_video_team
    section = @browser.find_element(:class, 'js-video-files-container')
    section.find_element(:class, 'button--primary').click
    @browser.find_element(:class, 'button--primary').click; sleep 2
  end

  def impersonate(client_id)
    @ui.fasttrack_login
    @browser.get 'https://qa.ncsasports.org/fasttrack/client/Search.do'

    # search for client via email address
    @ui.wait.until { @browser.find_element(:id, 'content').displayed? }
    @browser.find_element(:name, 'emailAddress').send_keys @recruit_email
    @browser.find_element(:name, 'button').click
    @browser.manage.timeouts.implicit_wait = 10

    table = @browser.find_element(:class, 'breakdowndatatable')
    column = table.find_elements(:tag_name, 'td')[1]
    column.find_element(:tag_name, 'button').click; sleep 1

    @browser.get "https://qa.ncsasports.org/clientrms/profile/recruiting_profile/#{client_id}/admin"
  end

  def open_tracking_note(client_id)
    @browser.get "https://qa.ncsasports.org/clientrms/profile/recruiting_profile/#{client_id}/admin"
    side_bar = @browser.find_elements(:class, 'side-bar')[1]
    nav_bar = side_bar.find_element(:class, 'm-nav-vert')
    nav_bar.find_elements(:tag_name, 'li')[1].click
  end
end