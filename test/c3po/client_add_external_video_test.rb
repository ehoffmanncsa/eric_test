# encoding: utf-8
require_relative '../test_helper'

# TS-247: C3PO Regression
# UI Test: Add External Video (As Client)
class ClientAddExternalVideo < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]
    
    @ui = LocalUI.new(true)
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@ui)
    Video.setup(@ui)

    POSSetup.buy_package(@email, 'elite')
    UIActions.user_login(@email)
  end

  def teardown
    @browser.quit
  end

  def get_video_count
    area = @browser.find_element(:class, 'mg-btm-1')
    section = area.find_elements(:class, 'remaining')[1]
    
    section.find_element(:class, 'js-external-videos-count').text.to_i
  end

  def test_client_add_external_video
    bad_msg = []; bad_count = []; failure = []

    # Add Youtube video
    Video.goto_video    
    counter = get_video_count

    Video.upload_youtube(false)
    browser_msg = @browser.find_element(:class, '_js-success-text')
    bad_msg << 'Youtube added success message not found' unless browser_msg.displayed?
    
    expect_msg = 'Your YouTube video was added to your profile.'
    msg = "Wrong success Youtube added message - #{browser_msg.text}"
    bad_msg << msg unless browser_msg.text == expect_msg
    
    counter -= 1
    msg = "Video count is #{get_video_count} after adding Youtube video"
    bad_count << msg unless counter == get_video_count 

    # Add Hudl video
    Video.goto_video
    counter = get_video_count

    Video.upload_hudl(false)
    browser_msg = @browser.find_element(:class, '_js-success-text')
    bad_msg << 'Hudl added success message not found' unless browser_msg.displayed?

    expect_msg = 'Your Hudl video was added to your profile.'
    msg = "Wrong success Hudl added message - #{browser_msg.text}"
    bad_msg << msg unless browser_msg.text == expect_msg

    counter -= 1
    msg = "Video count is #{get_video_count} after adding Hudl video"
    bad_count << msg unless counter == get_video_count

    failure = bad_msg + bad_count
    assert_empty failure
  end
end
