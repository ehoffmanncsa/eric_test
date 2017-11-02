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

    action = Video.new(@username, @recruit_email)
    action.upload_video
    action.teardown

    @ui.user_login(@username)
    @browser.get 'https://qa.ncsasports.org/clientrms/profile/video'

    @browser.find_element(:class, 'fa-remove').click
    modal = @browser.find_element(:class, 'video-confirm-modal')
    assert modal.find_element(:class, 'button--red').enabled?
    assert modal.find_element(:class, 'button--cancel').enabled?

    modal.find_element(:class, 'button--red').click; sleep 1
    assert (@browser.page_source.include? 'File deleted from your videos.'), 'Video deleted message not found'

    msg = "Cannot find message - You don't have any videos on your profile"
    assert (@browser.page_source.include? "You don't have any videos on your profile."), msg
  end
end