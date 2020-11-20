# encoding: utf-8
require_relative '../test_helper'

# TS-246: C3PO Regression
# UI Test: Add External Video (As Admin)
class AdminAddExternalVideo < Common
  def setup
    super

    # This client is a premium client for video test cases
    # If he goes stale causing test to fail, find another
    # replace email address and client id accordingly
    email = 'ncsa.automation+da42@gmail.com'
    client_id = '5784854'

    C3PO.setup(@browser)
    UIActions.fasttrack_login
    C3PO.impersonate(client_id)
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
    section = area.elements(class: 'remaining')[1]
    section.element(class: 'js-external-videos-count').text.to_i
  end

  def test_admin_add_external_video
    bad_msg = []; bad_count = []; failure = []

    C3PO.goto_video
    counter = get_video_count

    # Add Youtube video
    C3PO.upload_youtube
    browser_msg = @browser.element(class: '_js-success-text')
    bad_msg << 'Youtube added success message not found' unless browser_msg.present?

    expect_msg = 'Your YouTube video was added to your profile.'
    msg = "Wrong success Youtube added message - #{browser_msg.text}"
    bad_msg << msg unless browser_msg.text == expect_msg

    counter -= 1
    msg = "Video count is #{get_video_count} after adding Youtube video"
    bad_count << msg unless counter == get_video_count

    # Add Hudl video
    C3PO.upload_hudl
    browser_msg = @browser.element(class: '_js-success-text')
    bad_msg << 'Hudl added success message not found' unless browser_msg.present?

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
