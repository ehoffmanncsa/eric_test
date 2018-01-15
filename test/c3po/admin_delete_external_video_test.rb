# encoding: utf-8
require_relative '../test_helper'

# TS-250: C3PO Regression
# UI Test: Delete External Video (As Admin)
class AdminDeleteExternalVideo < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]

    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@browser)
    C3PO.setup(@browser)

    POSSetup.buy_package(@email, 'elite')
    C3PO.impersonate(@email)
  end

  def teardown
    @browser.close
  end

  def test_admin_delete_external_videos
    # Add video
    C3PO.goto_video
    C3PO.upload_youtube

    # find video and delete it
    item = @browser.element(:class, 'uploads-item')
    item.element(:class, 'remove').click

    modal = @browser.element(:class, 'mfp-content')
    modal.element(:class, 'js-button-confirm').click; sleep 1

    expected_msg = 'Video successfully deleted from your profile.'
    actual_msg = @browser.element(:class, '_js-success-text').text
    msg = "Video delete confirm message: #{actual_msg} not as expected: #{expected_msg}"
    assert_equal expected_msg, actual_msg, msg
  end
end
