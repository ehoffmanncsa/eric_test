# frozen_string_literal: true

require_relative '../test_helper'

# UI Test: Show Coaches video Milestone
class UploadVideoMilestoneTest < Common
  def setup
    super

    enroll_yr = 'sophomore'
    @package = 'mvp'
    @clientrms = Default.env_config['clientrms']

    _post, post_body = RecruitAPI.new(enroll_yr).ppost
    recruit_email = post_body[:recruit][:athlete_email]
    @sport_id = post_body[:recruit][:sport_id]

    UIActions.user_login(recruit_email)
    MSTestTemplate.setup(@browser, recruit_email, @package)
  end

  def teardown
    super
  end

  def check_milestone_complete
    @browser.goto 'https://qa.ncsasports.org/clientrms/education/resources/recruiting_drills'
    @browser.element(class: 'show-completed').click
    timeline_history = @browser.element(class: 'timeline-history')
    milestone = timeline_history.elements(css: 'li.milestone.point.complete').last
    title = milestone.element(class: 'info').element(class: 'title').text
    assert_equal 'Show Coaches Your Video', title, "#{title} - Expected: Show Coaches Your Video"
  end

  def go_to_all_pages_of_video_drill
    @browser.element(text: 'Upload your video').click
    @browser.element(text: "Let's Get Started!").element(class: 'fa-arrow-right').click
    @browser.element(class:'fa-check').click
    @browser.element('data-id': 'length').click
    youtube_button = @browser.element(class: 'selection', text: 'YouTube')
    youtube_button.click
    next_button = @browser.element('data-id': 'type')
    next_button.click
    @browser.goto 'https://qa.ncsasports.org/clientrms/profile/video#external_videos_container'
  end

  def upload_youtube
    url = 'https://www.youtube.com/watch?v=vaEWkjTZsy8'
    @browser.element(class: 'js-upload-options').element(class: 'fa-youtube').click
    form = @browser.form(id: 'profile-youtube-video-upload')
    # fill out the upload form
    form.text_field(id: 'external_video_title').set SecureRandom.hex(4)
    form.text_field(id: 'external_video_embed_code').set url


    form.button(name: 'commit').click
    Watir::Wait.while { form.element(class: 'action-spinner').present? }
  end

  def test_show_coaches_your_video_milestone_test
    MSTestTemplate.get_enrolled
    UIActions.goto_ncsa_university
    go_to_all_pages_of_video_drill
    upload_youtube
    check_milestone_complete
  end
end
