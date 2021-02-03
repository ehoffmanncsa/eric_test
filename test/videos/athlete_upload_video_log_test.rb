# frozen_string_literal: true

require_relative '../test_helper'

# Video regression
# UI Test: Student athlete is able upload NCSA video and video logs
class AthleteAddVideoLogTest < Common
  def setup
    super

    enroll_yr = 'junior'
    @package = 'champion'
    @clientrms = Default.env_config['clientrms']

    post, post_body = RecruitAPI.new(enroll_yr).ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    @client_id = post['client_id']

    UIActions.setup(@browser)

    UIActions.user_login(@recruit_email)
    MSTestTemplate.setup(@browser, @recruit_email, @package)

    C3PO.setup(@browser)
    @file_name = 'sample.mp4'
    @video_log_docx = 'video_log_test_file.docx'
    @video_log_png = 'video_log_test_png_file.png'
    @video_log_jpg = 'video_log_test_jpg_file.jpg'
    @video_log_pdf = 'video_log_test_pdf_file.pdf'
  end

  def teardown
    super
  end

  def test_athlete_play_published_video
    # upload video as user
    MSTestTemplate.get_enrolled
    C3PO.goto_video
    C3PO.upload_video(@file_name)
    C3PO.upload_video_log(@video_log_docx)
    C3PO.upload_video_log(@video_log_png)
    C3PO.upload_video_log(@video_log_jpg)
    C3PO.upload_video_log(@video_log_pdf)

    C3PO.send_to_video_team

    # admin verify video and video log uploads
    UIActions.fasttrack_login
    C3PO.impersonate(@client_id)
    C3PO.goto_publish

    # verify the published NCSA video title displays on the preview profile page
    failure = []
    failure << 'NCSA video file not displaying' unless @browser.html.include? 'sample.mp4'
    failure << 'Video log docx file not displaying' unless @browser.html.include? 'video_log_test_file.docx'
    failure << 'Video log png file not displaying' unless @browser.html.include? 'video_log_test_png_file.png'
    failure << 'Video log jpg file not displaying' unless @browser.html.include? 'video_log_test_jpg_file.jpg'
    failure << 'Video log pdf file not displaying' unless @browser.html.include? 'video_log_test_pdf_file.pdf'
    assert_empty failure
  end
end
