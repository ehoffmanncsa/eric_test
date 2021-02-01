# encoding: utf-8
require_relative '../test_helper'

# TS-18: Video regression
# UI Test: Admin/video editing team user can Publish a Video
class AdminPublishVideoTest < Minitest::Test
  def setup
    skip
    _post, post_body = RecruitAPI.new.ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    add_premium

    @ui = UI.new 'local', 'chrome'
    @browser = @ui.driver
    UIActions.setup(@browser)
    C3PO.setup(@browser)

    @file_name = 'sample.mov'
  end

  def add_premium
    ui = UI.new 'local', 'firefox'
    browser = ui.driver
    MSSetup.setup(browser)
    MSSetup.buy_package(@recruit_email, 'elite')
    browser.close
  end

  def teardown
    @browser.close
  end

  def check_uploaded_video_table
    failure = []
    table = @browser.element(:css, 'table.m-tbl.uploaded-videos')
    row1 = table.elements(:tag_name, 'tr')[0]
    row2 = table.elements(:tag_name, 'tr')[1]
    columns = row2.elements(:tag_name, 'td').to_a
    headers = row1.elements(:tag_name, 'th').to_a

    i = 0
    columns.pop
    columns.each do |c|
      next if i == 6 || i == 8
      failure << "#{headers[i].text} is empty" if c.text.empty?
      i += 1
    end

    assert_empty failure
  end

  def check_publish_video_table
    failure = []
    table = @browser.element(:id, 'cvt-videos')
    row1 = table.elements(:tag_name, 'tr').first
    failure << 'Upload button not enabled' unless row1.element(:class, 'fa-upload').enabled?
    failure << 'Edit button not enabled' unless row1.element(:class, 'fa-edit').enabled?
    failure << 'Delete button not enabled' unless row1.element(:class, 'fa-times-circle').enabled?

    assert_empty failure
  end

  def test_admin_publish_video
    # upload video as user
    UIActions.user_login(@recruit_email)
    C3PO.goto_video
    C3PO.upload_video(@file_name)
    C3PO.send_to_video_team

    # now check the video publish page as admin
    C3PO.impersonate(@recruit_email)
    C3PO.goto_publish
    C3PO.activate_first_row_of_new_video
    check_uploaded_video_table
    check_publish_video_table

    # publish it
    C3PO.publish_video(@file_name)

    # now check if the published video shows up in the athlete's profile
    # giving 180 seconds grace period in helper method
    thumbnail = C3PO.wait_for_video_thumbnail; sleep 1
    assert thumbnail.enabled?, 'Video thumbnail not clickable'
  end
end
