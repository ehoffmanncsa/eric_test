# encoding: utf-8
require_relative '../test_helper'

# TS-206: NCSA University Regression
# UI Test: Show Coaches Your Transcript Milestone
class UploadTranscriptMilestoneTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]

    @ui = LocalUI.new(true)
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@ui)

    POSSetup.buy_package(@email, 'elite')
    UIActions.user_login(@email)
  end

  def teardown
    @browser.quit
  end

  def check_uploaded_file(file_name)
    @browser.find_element(:link_text, 'Official Transcript').click; sleep 5
    @browser.switch_to.window(@browser.window_handles[1].to_s)

    url = @browser.current_url
    msg = "Official Transcript hyperlink redirect not including #{file_name}"
    assert (url.include? file_name), msg
    
    title = @browser.title
    msg = "Transcript page souce title incorrect - #{title}"
    assert_equal "Transcript - sample_transcript.pdf", title, msg
  end

  def check_milestone_complete
    @browser.switch_to.window(@browser.window_handles[0].to_s); sleep 1
    @browser.find_element(:class, 'bg-overlay').location_once_scrolled_into_view; sleep 1
    @browser.find_element(:class, 'fa-bars').click; sleep 1

    nav_menu = @browser.find_element(:tag_name, 'nav')
    dashboard = nav_menu.find_elements(:tag_name, 'a')[0].attribute('href')
    @browser.get dashboard
    UIActions.goto_ncsa_university

    @browser.find_element(:class, 'show-completed').click; sleep 2
    timeline_history = @browser.find_element(:class, 'timeline-history')
    milestone = timeline_history.find_elements(:css, 'li.milestone.point.complete').last
    title = milestone.find_element(:class, 'info').find_element(:class, 'title').text
    assert_equal 'Show Coaches Your Transcript', title, "#{title} - Expected: Show Coaches Your Transcript"
  end

  def test_upload_transcript_milestone
    file_name = 'sample_transcript.pdf'
    path = File.absolute_path("test/ncsa_university/#{file_name}")
    UIActions.goto_ncsa_university
    milestone = @browser.find_element(:link_text, 'Upload your transcript').click

    for i in 1 .. 3
      sticky_wrap = @browser.find_element(:class, 'sticky-wrap')
      if @browser.current_url.include? '/upload'
        sticky_wrap.find_element(:id, 'transcript_file').send_keys path
        button = @browser.find_element(:name, 'commit')
        click = "arguments[0].click()"
        @browser.execute_script(click, button); sleep 5
      else
        sticky_wrap.find_element(:class, 'button--wide').click; sleep 3
      end
    end

    check_uploaded_file(file_name)
    check_milestone_complete
  end
end
