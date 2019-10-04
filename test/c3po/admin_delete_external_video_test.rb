# encoding: utf-8
require_relative '../test_helper'

# TS-250: C3PO Regression
# UI Test: Delete External Video (As Admin)
class AdminDeleteExternalVideo < Common
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
    super
  end

  def test_admin_delete_external_videos
    # Add video
    C3PO.goto_video
    C3PO.upload_youtube

    # find video and delete it
    item = @browser.element(class: 'uploads-item')
    item.element(class: 'remove').click

    modal = @browser.element(class: 'mfp-content')
    modal.element(class: 'js-button-confirm').click; sleep 1

    expected_msg = 'Video successfully deleted from your profile.'
    actual_msg = @browser.element(class: '_js-success-text').text
    msg = "Video delete confirm message: #{actual_msg} not as expected: #{expected_msg}"
    assert_equal expected_msg, actual_msg, msg
  end
end
