# encoding: utf-8
require_relative '../test_helper'

# TS-247: C3PO Regression
# UI Test: Add External Video (As Client)
class ClientAddExternalVideo < Common
  def setup
    super

    # This test case is specifically for Football premium
    # Attempt to use a static MVP client
    email = 'esport@yopmail.com'

    C3PO.setup(@browser)
    UIActions.user_login(email, 'ncsa1333')
    C3PO.goto_video
  end

  def teardown
    delete_video
    super
  end

  def delete_video
    begin
      while delete_video_btn
        delete_video_btn.click
        popup = @browser.div(class: %w[video-confirm-modal white-popup])
        popup.div(class: 'button--red').click
      end
    rescue
      # break out of loop
    end
  end

  def delete_video_btn
    video_list = @browser.div(class: 'video-uploads').ul(class: 'uploads').lis("data-video-type": 'external')
    video_list.first.span(class: 'js-delete-external-video')
  rescue
    # Do nothing here
  end

  def get_video_count
    area = @browser.element(class: 'mg-btm-1')
    section = area.elements(class: 'remaining').to_a

    section[1].element(class: 'js-external-videos-count').text.to_i
  end

  def test_client_add_external_video_twitch
    bad_msg = []; bad_count = []; failure = []

    # Add Twitch video
    counter = get_video_count

    C3PO.upload_twitch(false)
    browser_msg = @browser.element(class: '_js-success-text')
    bad_msg << 'Twitch added success message not found' unless browser_msg.present?

    expect_msg = 'Your Twitch video was added to your profile.'
    msg = "Wrong success Twitch added message - #{browser_msg.text}"
    bad_msg << msg unless browser_msg.text == expect_msg

    counter -= 1
    msg = "Video count is #{get_video_count} after adding Twitch video"
    bad_count << msg unless counter == get_video_count
  

    failure = bad_msg + bad_count
    assert_empty failure
  end
end
