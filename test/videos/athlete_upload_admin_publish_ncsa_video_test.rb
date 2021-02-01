# frozen_string_literal: true

require_relative '../test_helper'

# TS-17: Video regression
# UI Test: Student athlete is able play video on Preview Profile UX
class AthletePlayPublishedVideoTest < Common
  def setup
    super

    enroll_yr = 'freshman'
    @package = 'elite'
    @clientrms = Default.env_config['clientrms']

    post, post_body = RecruitAPI.new(enroll_yr).ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    @client_id = post['client_id']

    UIActions.user_login(@recruit_email)
    MSTestTemplate.setup(@browser, @recruit_email, @package)

    UIActions.setup(@browser)
    C3PO.setup(@browser)
    @file_name = 'sample.mp4'
  end

  def teardown
    super
  end

  def note_NCSA_video_count_before
    area = @browser.element(class: 'mg-btm-1')
    before = area.element(class: 'remaining')

    @video_count_before = before.element(class: 'number').text.to_i
  end

  def note_NCSA_video_count_after
    area = @browser.element(class: 'mg-btm-1')
    after = area.element(class: 'remaining')

    @video_count_after = after.element(class: 'number').text.to_i
  end

  def check_ncsa_videos_left_count_decreased
    # get initial ncsa videos left video count
    video_count_before_publish = @video_count_before

    video_count_before_publish -= 1
    sleep 2

    # compare video count before and after publish video
    new_video_count = @video_count_after

    assert_equal video_count_before_publish, new_video_count, 'NCSA video left count did not decrease by 1 after publishing'
  end

  def test_athlete_play_published_video
    # upload video as user
    MSTestTemplate.get_enrolled
    C3PO.goto_video
    C3PO.upload_video(@file_name)
    C3PO.send_to_video_team

    # publish video as admin
    UIActions.fasttrack_login
    C3PO.impersonate(@client_id)
    C3PO.goto_video
    note_NCSA_video_count_before
    C3PO.goto_publish
    C3PO.activate_first_row_of_new_video
    C3PO.open_edit_new_video
    C3PO.enter_title_new_video
    C3PO.save_video_edits
    C3PO.publish_video(@file_name)
    sleep 2

    # check if the url in data-transcodings has the right file name
    C3PO.wait_for_video_thumbnail
    video = @browser.element(class: 'video-link')
    data_transcodings = video.attribute('data-transcodings')
    refute_empty data_transcodings, "Video's data-transcodings attribute is nil"

    assert (data_transcodings.to_s.include? @file_name), "Video's data-transcodings not including uploaded file"

    video.click; sleep 1
    video_player = @browser.element(id: 'video-player')
    assert video_player.present?, 'Video player not found'

    # verify the published NCSA video title displays on the preview profile page
    failure = []
    failure << 'Video title not displaying' unless @browser.html.include? 'Athlete Highlight Video'
    assert_empty failure

    C3PO.goto_video
    note_NCSA_video_count_after
    check_ncsa_videos_left_count_decreased
  end
end
