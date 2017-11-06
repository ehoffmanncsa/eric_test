# encoding: utf-8
require_relative '../test_helper'
require 'securerandom'

# TS-17: Video regression
# UI Test: Student athlete is able play video on Preview Profile UX
class AthletePlayPublishedVideoTest < Minitest::Test
  def setup
    @ui = LocalUI.new(true)
    @browser = @ui.driver

    resp_code, _resp_body, @username = RecruitAPI.new.ppost
    raise "POST new recuite to API gives #{resp_code}" unless resp_code.eql? 200

    @recruit_email = "#{@username}@ncsasports.org"
    @file_name = 'sample.mp4'
  end

  def teardown
    @browser.quit
  end

  def test_athlete_play_published_video
    buy_premium_package
    publish_video

    # check if the url in data-transcodings has the right file name
    Video.goto_preview_profile
    Video.wait_for_video_thumbnail
    video = @browser.find_element(:class, 'video-link')
    data_transcodings = video.attribute('data-transcodings')
    refute_empty data_transcodings, "Video's data-transcodings attribute is nil"

    assert (data_transcodings.include? @file_name), "Video's data-transcodings not including uploaded file"

    # check video thumbnail when clicked:
    # play console is displayed
    # play console pointing to the right url (with right file name)
    video.click; sleep 1
    video_player = @browser.find_element(:id, 'video-player')
    assert video_player.displayed?, 'Video player not found'

    mep_1 = video_player.find_element(:class, 'container')
    player = mep_1.find_element(:id, '_player').find_element(:class, 'mejs-video')
    player_cont = player.find_element(:id, '_me-player-cont')
    url = player_cont.find_elements(:tag_name, 'source')[1].attribute('src')

    assert (url.include? @file_name), "Video player url pointing to wrong file #{url} .. Expect #{@file_name}"
  end

  def buy_premium_package
    POSSetup.setup(@ui)
    POSSetup.buy_package(@recruit_email, @username, 'elite')
  end

  def publish_video
    Video.setup(@ui, @username)

    Video.impersonate(@recruit_email)
    Video.goto_publish
    Video.activate_first_row_of_new_video
    Video.publish_video(@file_name)
  end
end
