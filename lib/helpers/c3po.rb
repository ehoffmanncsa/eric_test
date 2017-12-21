# encoding: utf-8
require_relative '../../test/test_helper'

# This helper is to help in performing video related actions
module C3PO
  def self.setup(ui_object)
    @browser = ui_object.driver
    UIActions.setup(@browser)
  end

  def self.teardown
    @browser.quit
  end

  def self.upload_video(file = nil)
    file ||= 'sample.mp4'
    path = File.absolute_path("test/videos/#{file}")

    # Go to video page and open upload section
    @browser.find_element(:class, 'js-upload-options').find_element(:class, 'fa-plus').click

    # fill out the upload form
    @browser.find_element(:id, 'uploaded_video_as_is').find_elements(:tag_name, 'option')[1].click
    @browser.find_element(:id, 'uploaded_video_position').send_keys SecureRandom.hex(4)
    @browser.find_element(:id, 'uploaded_video_jersey_number').send_keys SecureRandom.hex(4)
    @browser.find_element(:id, 'uploaded_video_jersey_color').send_keys SecureRandom.hex(4)

    # send in file path and upload
    @browser.find_element(:id, 'profile-video-upload-file-input').send_keys path
    @browser.find_element(:class, 'action-buttons').find_element(:class, 'button--primary').click; sleep 3
  end

  def self.upload_youtube(admin = true)
    url = 'https://www.youtube.com/watch?v=YtfZeoFU0J0'
    @browser.find_element(:class, 'js-upload-options').find_element(:class, 'fa-youtube').click
    form = @browser.find_element(:id, 'profile-youtube-video-upload')

    # fill out the upload form
    form.find_element(:id, 'external_video_title').send_keys SecureRandom.hex(4)
    form.find_element(:id, 'external_video_embed_code').send_keys url
    form.find_element(:id, 'verified').click if admin

    form.submit
    UIActions.wait.until { 
      form.find_element(:class, 'action-spinner').attribute('style') == 'display: none;'
    }
  end

  def self.upload_hudl(admin = true)
    url = 'http://www.hudl.com/video/3/8650926/58f3b097bee0b52f8c96bfd5'
    @browser.find_element(:class, 'js-upload-options').find_element(:class, 'fa-custom-hudl').click
    form = @browser.find_element(:id, 'hudl-embed-video-upload')

    # fill out the upload form
    form.find_element(:id, 'external_video_title').send_keys SecureRandom.hex(4)
    form.find_element(:id, 'external_video_embed_code').send_keys url
    form.find_element(:id, 'verified').click if admin

    form.submit
    UIActions.wait.until { 
      form.find_element(:class, 'action-spinner').attribute('style') == 'display: none;'
    }
  end

  def self.send_to_video_team
    section = @browser.find_element(:class, 'js-video-files-container')
    section.find_element(:class, 'button--primary').click; sleep 2
    @browser.find_element(:class, 'button--primary').click; sleep 1
  end

  def self.impersonate(recruit_email)
    UIActions.fasttrack_login
    client_seach = 'https://qa.ncsasports.org/fasttrack/client/Search.do'
    @browser.get client_seach

    # search for client via email address
    UIActions.wait.until { @browser.find_element(:id, 'content').displayed? }

    Timeout::timeout(180) {
      loop do
        begin
          @browser.find_element(:name, 'emailAddress').send_keys recruit_email
          @browser.find_element(:name, 'button').click
          @browser.manage.timeouts.implicit_wait = 5

          @table = @browser.find_element(:class, 'breakdowndatatable')
        rescue => e
          @browser.find_element(:name, 'emailAddress').clear
          @browser.get client_seach; sleep 5 ; retry
        end

        break if @table
      end
    }

    column = @table.find_elements(:tag_name, 'td')[1]
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

  def self.activate_first_row_of_new_video
    new_video_btn = @browser.find_elements(:class, 'm-button-gray').first
    new_video_btn.click
  end

  def self.publish_video(file = nil)
    file ||= 'sample.mp4'
    path = File.absolute_path("test/videos/#{file}")

    row = @browser.find_element(:id, 'cvt-videos').find_elements(:tag_name, 'tr')[0]
    video_id = row.attribute('id').split('-').last

    # Execute javascript to inject associate id for video
    assoc_id = @browser.find_element(:id, 'assoc_id')
    inject_id = "return arguments[0].value = #{video_id}"
    @browser.execute_script(inject_id, assoc_id); sleep 0.5

    @browser.find_element(:id, 'direct-upload').find_element(:id, 'file').send_keys path; sleep 1
    @browser.find_element(:id, 'email_subject').send_keys SecureRandom.hex(4)
    @browser.find_element(:name, 'commit').click; sleep 1
  end

  def self.goto_preview_profile
    @browser.find_element(:class, 'profile-button-link').click; sleep 1
    @browser.switch_to.window(@browser.window_handles[2].to_s)
  end

  def self.wait_for_video_thumbnail
    Timeout::timeout(300) {
      loop do
        begin
          @browser.navigate.refresh
          @thumbnail = @browser.find_element(:class, 'thumbnail')
        rescue => e
          retry
        end

        break if @thumbnail
      end
    }
  end
end
