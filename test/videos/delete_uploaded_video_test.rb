# encoding: utf-8
require_relative '../test_helper'
require 'securerandom'

# TS-7: Video regression
# UI Test: Student athlete is able to delete a video
#          from the “MY VIDEO FILES” section of video page
class DeleteUploadedVideoTest < Minitest::Test
  def setup
    @ui = LocalUI.new(true)
    @browser = @ui.driver

    resp_code, resp_body, @username = RecruitAPI.new.ppost
    raise "POST new recuite to API gives #{resp_code}" unless resp_code.eql? 200

    @client_id = resp_body['client_id']
    @recruit_email = "#{@username}@ncsasports.org"
  end

  def teardown
    @browser.quit
  end

  def test_delete_a_video
    POSSetup.new.buy_package(@recruit_email, @username, 'elite')

    @ui.user_login(@username)
    @browser.get 'https://qa.ncsasports.org/clientrms/profile/video'

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

    @browser.find_element(:class, 'fa-remove').click
    modal = @browser.find_element(:class, 'video-confirm-modal')
    assert modal.find_element(:class, 'button--red').enabled?
    assert modal.find_element(:class, 'button--cancel').enabled?

    modal.find_element(:class, 'button--red').click; sleep 1
    assert @browser.page_source.include? "File deleted from your videos."
    assert @browser.page_source.include? "You don't have any videos on your profile."
  end
end