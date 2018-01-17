# encoding: utf-8
require_relative '../test_helper'

# TS-7: Video regression
# UI Test: Student athlete is able to delete a video
#          from the “MY VIDEO FILES” section of video page
class DeleteUploadedVideoTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@browser)
    C3PO.setup(@browser)

    POSSetup.buy_package(@recruit_email, 'elite')
    UIActions.user_login(@recruit_email)
  end

  def teardown
    @browser.close
  end


  def test_delete_a_video
    file_name = 'sample.mp4'
    C3PO.goto_video
    C3PO.upload_video(file_name)

    container = @browser.element(:class, 'js-video-files-container')

    # now delete and see if it is successfully deleted
    @browser.element(:class, 'fa-remove').click
    modal = @browser.element(:class, 'video-confirm-modal')
    assert modal.element(:class, 'button--red').enabled?
    assert modal.element(:class, 'button--cancel').enabled?

    modal.element(:class, 'button--red').click; sleep 1
    assert (@browser.html.include? 'File deleted from your videos.'), 'Video deleted message not found'

    msg = "Cannot find message - You don't have any videos on your profile"
    assert (@browser.html.include? "You don't have any videos on your profile."), msg
  end
end