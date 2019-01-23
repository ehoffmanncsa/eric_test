# encoding: utf-8
require_relative '../test_helper'

# TS-17: Video regression
# UI Test: Student athlete is able play video on Preview Profile UX
class AthletePlayPublishedVideoTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    add_premium

    @ui = UI.new 'local', 'chrome'
    @browser = @ui.driver
    UIActions.setup(@browser)
    C3PO.setup(@browser)

    @file_name = 'sample.mp4'
  end

  def add_premium
    ui = UI.new 'local', 'firefox'
    browser = ui.driver
    MSSetup.setup(browser)
    MSSetup.buy_package(@recruit_email, 'elite')
    browser.close
  end

  def teardown
    @browser.close
  end

  def test_athlete_play_published_video
    # upload video as user
    UIActions.user_login(@recruit_email)
    C3PO.goto_video
    C3PO.upload_video(@file_name)
    C3PO.send_to_video_team

    # publish video as admin
    C3PO.impersonate(@recruit_email)
    C3PO.goto_publish
    C3PO.activate_first_row_of_new_video
    C3PO.publish_video(@file_name)

    # check if the url in data-transcodings has the right file name
    C3PO.wait_for_video_thumbnail
    video = @browser.element(:class, 'video-link')
    data_transcodings = video.attribute('data-transcodings')
    refute_empty data_transcodings, "Video's data-transcodings attribute is nil"

    assert (data_transcodings.to_s.include? @file_name), "Video's data-transcodings not including uploaded file"

    # check video thumbnail when clicked:
    # play console is displayed
    # play console pointing to the right url (with right file name)
    video.click; sleep 1
    video_player = @browser.element(:id, 'video-player')
    assert video_player.visible?, 'Video player not found'

    mep_1 = video_player.element(:class, 'container')
    player = mep_1.element(:id, '_player').element(:class, 'mejs-video')
    player_cont = player.element(:id, '_me-player-cont')
    url = player_cont.elements(:tag_name, 'source')[1].attribute('src')

    assert (url.include? @file_name), "Video player url pointing to wrong file #{url} .. Expect #{@file_name}"
  end
end
