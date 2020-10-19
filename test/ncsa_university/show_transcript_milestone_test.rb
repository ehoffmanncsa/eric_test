# encoding: utf-8
require_relative '../test_helper'

# TS-206: NCSA University Regression
# UI Test: Show Coaches Your Transcript Milestone
class UploadTranscriptMilestoneTest < Common
  def setup
    super

    enroll_yr = 'senior'
    @package = 'champion'
    @clientrms = Default.env_config['clientrms']

    _post, post_body = RecruitAPI.new(enroll_yr).ppost
    recruit_email = post_body[:recruit][:athlete_email]

    UIActions.user_login(recruit_email)
    MSTestTemplate.setup(@browser, recruit_email, @package)

   @file_name = 'sample_transcript.pdf'
   @path = File.absolute_path("test/ncsa_university/#{@file_name}")
  end

  def teardown
    super
  end

 def check_uploaded_file
     @browser.element(class:'transcript').link.click
     sleep 2
     @browser.window(index: 1).use

    url = @browser.url
    msg = "Official Transcript hyperlink redirect not including #{@file_name}"
    assert (url.include? @file_name), msg

    title = @browser.title
    msg = "Transcript page souce title incorrect - #{title}"
    assert_equal "Transcript - sample_transcript.pdf", title, msg
  end

  def check_milestone_complete
    @browser.goto 'https://qa.ncsasports.org/clientrms/education/resources/recruiting_drills'
    @browser.element(class: 'show-completed').click
    timeline_history = @browser.element(class: 'timeline-history')
    milestone = timeline_history.elements(css: 'li.milestone.point.complete').last
    title = milestone.element(class: 'info').element(:class, 'title').text
    assert_equal 'Show Coaches Your Transcript', title, "#{title} - Expected: Show Coaches Your Transcript"
  end

  def content
    @browser.element(class:'content-area')
  end

  def upload_file
    content.element(id:'transcript_file').send_keys @path
    button = @browser.element(name:'commit')
    click = "arguments[0].click()"
    @browser.execute_script(click, button); sleep 3
  end

  def test_upload_transcript_milestone
      MSTestTemplate.get_enrolled
      UIActions.goto_ncsa_university

    @browser.link(text:'Upload your transcript').click
    content.element(class:'button--wide').click

    upload_file
    Watir::Wait.until { content.present? }
    content.element(class:'button--wide').click


    check_uploaded_file
    check_milestone_complete
  end
end
