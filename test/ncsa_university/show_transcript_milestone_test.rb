# encoding: utf-8
require_relative '../test_helper'

# TS-206: NCSA University Regression
# UI Test: Show Coaches Your Transcript Milestone
class UploadTranscriptMilestoneTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]

    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@browser)

    POSSetup.buy_package(@email, 'elite')
    UIActions.clear_cookies
    UIActions.user_login(@email)

    @file_name = 'sample_transcript.pdf'
    @path = File.absolute_path("test/ncsa_university/#{@file_name}")
  end

  def teardown
    @browser.close
  end

  def check_uploaded_file
    @browser.link(:text, 'Official Transcript').click; sleep 2
    @browser.window(:index, 1).use

    url = @browser.url
    msg = "Official Transcript hyperlink redirect not including #{@file_name}"
    assert (url.include? @file_name), msg

    title = @browser.title
    msg = "Transcript page souce title incorrect - #{title}"
    assert_equal "Transcript - sample_transcript.pdf", title, msg
  end

  def check_milestone_complete
    @browser.goto 'https://qa.ncsasports.org/clientrms/dashboard/show'
    begin
      Watir::Wait.until { @browser.div(:class, 'mfp-content').visible? }
      popup = @browser.div(:class, 'mfp-content')
      popup.element(:class, 'close-popup').click; sleep 1
    rescue; end

    UIActions.goto_ncsa_university
    @browser.element(:class, 'show-completed').click
    timeline_history = @browser.element(:class, 'timeline-history')
    milestone = timeline_history.elements(:css, 'li.milestone.point.complete').last
    title = milestone.element(:class, 'info').element(:class, 'title').text
    assert_equal 'Show Coaches Your Transcript', title, "#{title} - Expected: Show Coaches Your Transcript"
  end

  def content
    @browser.element(:class, 'content-area')
  end

  def upload_file
    content.element(:id, 'transcript_file').send_keys @path
    button = @browser.element(:name, 'commit')
    click = "arguments[0].click()"
    @browser.execute_script(click, button); sleep 3
  end

  def test_upload_transcript_milestone
    UIActions.goto_ncsa_university
    @browser.link(:text, 'Upload your transcript').click
    content.element(:class, 'button--wide').click

    upload_file
    Watir::Wait.until { content.visible? }
    content.element(:class, 'button--wide').click

    check_uploaded_file
    check_milestone_complete
  end
end
