# encoding: utf-8
require_relative '../../test/test_helper'

# This helper is to help in performing video related actions
module Video
  def self.setup(ui, username)
    @ui = ui
    @browser = ui.driver

    @username = username
  end

  def self.teardown
    @browser.quit
  end

  def self.upload_video(path = 'test/videos/sample.mp4')
    path = File.absolute_path(path)
    @ui.user_login(@username)

    # Go to video page and open upload section
    goto_video
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


  def self.send_to_video_team
    section = @browser.find_element(:class, 'js-video-files-container')
    section.find_element(:class, 'button--primary').click
    @browser.find_element(:class, 'button--primary').click; sleep 2
  end

  def self.impersonate(recruit_email)
    @ui.fasttrack_login
    @browser.get 'https://qa.ncsasports.org/fasttrack/client/Search.do'

    # search for client via email address
    @ui.wait.until { @browser.find_element(:id, 'content').displayed? }

    begin
      retries ||= 0
      @browser.find_element(:name, 'emailAddress').send_keys recruit_email
      @browser.find_element(:name, 'button').click
      @browser.manage.timeouts.implicit_wait = 8
      table = @browser.find_element(:class, 'breakdowndatatable')
    rescue
      retry if (retries += 1) < 3
    end

    @browser.find_element(:name, 'emailAddress').send_keys recruit_email
    @browser.find_element(:name, 'button').click
    @browser.manage.timeouts.implicit_wait = 5
    table = @browser.find_element(:class, 'breakdowndatatable')

    column = table.find_elements(:tag_name, 'td')[1]
    column.find_element(:tag_name, 'button').click; sleep 1

    @browser.switch_to.window(@browser.window_handles[1].to_s)
  end

  def self.open_tracking_note(client_id)
    @browser.get "https://qa.ncsasports.org/clientrms/profile/recruiting_profile/#{client_id}/admin"
    side_bar = @browser.find_elements(:class, 'side-bar')[1]
    nav_bar = side_bar.find_element(:class, 'm-nav-vert')
    nav_bar.find_elements(:tag_name, 'li')[1].click
  end

  def self.goto_video
    @browser.find_element(:id, 'profile_summary_button').click
    @browser.find_element(:class, 'subheader').find_element(:id, 'edit_video_link').click
  end

  def self.goto_publish
    goto_video
    @browser.find_element(:class, 'pub').click
  end
end