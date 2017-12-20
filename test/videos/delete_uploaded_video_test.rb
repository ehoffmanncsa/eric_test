# encoding: utf-8
require_relative '../test_helper'

# TS-7: Video regression
# UI Test: Student athlete is able to delete a video
#          from the “MY VIDEO FILES” section of video page
class DeleteUploadedVideoTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    
    @ui = LocalUI.new(true)
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@ui)
    Video.setup(@ui)

    POSSetup.buy_package(@recruit_email, 'elite')
    UIActions.user_login(@recruit_email)
  end

  def teardown
    @browser.quit
  end


  def test_delete_a_video
    file_name = 'sample.mp4'
    Video.goto_video
    Video.upload_video(file_name)

    container = @browser.find_element(:class, 'js-video-files-container')
    UIActions.wait.until { container.find_element(:class, 'row').displayed? }

    # now delete and see if it is successfully deleted
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