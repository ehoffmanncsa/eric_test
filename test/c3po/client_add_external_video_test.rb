# encoding: utf-8
require_relative '../test_helper'

# TS-247: C3PO Regression
# UI Test: Add External Video (As Client)
class ClientAddExternalVideo < Common
  def setup
    super

    # This test case is specifically for Football premium
    # Attempt to use a static MVP client
    email = 'ncsa.automation+e6cc@gmail.com'

    C3PO.setup(@browser)
    UIActions.user_login(email, 'ncsa1333')
    C3PO.goto_video
  end

  def teardown
    delete_video
    delete_video
    super
  end

  def delete_video
  item = @browser.element(class: 'uploads-item')
  item.element(class: 'remove').click

  sleep 3

  modal = @browser.element(class: 'mfp-content')
  modal.element(text: 'Delete').click; sleep 2
  end

  def get_video_count
    area = @browser.element(class: 'mg-btm-1')
    section = area.elements(class: 'remaining').to_a

    section[1].element(class: 'js-external-videos-count').text.to_i
  end

  def test_client_add_external_video
    bad_msg = []; bad_count = []; failure = []

    # Add Youtube video
    counter = get_video_count

    C3PO.upload_youtube(false)
    browser_msg = @browser.element(class: '_js-success-text')
    bad_msg << 'Youtube added success message not found' unless browser_msg.present?

    expect_msg = 'Your YouTube video was added to your profile.'
    msg = "Wrong success Youtube added message - #{browser_msg.text}"
    bad_msg << msg unless browser_msg.text == expect_msg

    counter -= 1
    msg = "Video count is #{get_video_count} after adding Youtube video"
    bad_count << msg unless counter == get_video_count

    C3PO.upload_hudl(false)
    browser_msg = @browser.element(class: '_js-success-text')
    bad_msg << 'Hudl added success message not found' unless browser_msg.present?

    expect_msg = 'Your Hudl video was added to your profile.'
    msg = "Wrong success Hudl added message - #{browser_msg.text}"
    bad_msg << msg unless browser_msg.text == expect_msg

    counter -= 1
    msg = "Video count is #{get_video_count} after adding Hudl video"
    bad_count << msg unless counter == get_video_count

    failure = bad_msg + bad_count
    @browser.refresh
    assert_empty failure
  end
end
