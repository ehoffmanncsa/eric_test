# encoding: utf-8
require_relative '../test_helper'

# TS-247: C3PO Regression
# UI Test: Add External Video (As Client)
class ClientAddExternalVideo < Common
  def setup
    super

    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]

    MSSetup.setup(@browser)
    C3PO.setup(@browser)

    MSSetup.buy_package(@email, 'elite')
    UIActions.user_login(@email)
  end

  def teardown
    super
  end

  def get_video_count
    area = @browser.element(:class, 'mg-btm-1')
    section = area.elements(:class, 'remaining').to_a

    section[1].element(:class, 'js-external-videos-count').text.to_i
  end

  def test_client_add_external_video
    bad_msg = []; bad_count = []; failure = []

    # Add Youtube video
    C3PO.goto_video
    counter = get_video_count

    C3PO.upload_youtube(false)
    browser_msg = @browser.element(:class, '_js-success-text')
    bad_msg << 'Youtube added success message not found' unless browser_msg.visible?

    expect_msg = 'Your YouTube video was added to your profile.'
    msg = "Wrong success Youtube added message - #{browser_msg.text}"
    bad_msg << msg unless browser_msg.text == expect_msg

    counter -= 1
    msg = "Video count is #{get_video_count} after adding Youtube video"
    bad_count << msg unless counter == get_video_count

    # Add Hudl video
    C3PO.goto_video
    counter = get_video_count

    C3PO.upload_hudl(false)
    browser_msg = @browser.element(:class, '_js-success-text')
    bad_msg << 'Hudl added success message not found' unless browser_msg.visible?

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
