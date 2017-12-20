# encoding: utf-8
require_relative '../test_helper'

# TS-18: Video regression
# UI Test: Admin/video editing team user can Publish a Video
class AdminPublishVideoTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @recruit_email = post_body[:recruit][:athlete_email]

    @ui = LocalUI.new(true)
    @browser = @ui.driver
    Video.setup(@ui)
    POSSetup.setup(@ui)
    UIActions.setup(@browser)

    POSSetup.buy_package(@recruit_email, 'elite')
    UIActions.user_login(@recruit_email)

    @file_name = 'sample.mov'
    Video.goto_video
    Video.upload_video(@file_name)
    Video.send_to_video_team
  end

  def teardown
    @browser.quit
  end

  def check_uploaded_video_table
    failure = []
    table = @browser.find_element(:css, 'table.m-tbl.uploaded-videos')
    row1 = table.find_elements(:tag_name, 'tr')[0]
    row2 = table.find_elements(:tag_name, 'tr')[1]
    columns = row2.find_elements(:tag_name, 'td')
    headers = row1.find_elements(:tag_name, 'th')

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
    table = @browser.find_element(:id, 'cvt-videos')
    row1 = table.find_elements(:tag_name, 'tr').first
    failure << 'Upload button not enabled' unless row1.find_element(:class, 'fa-upload').enabled?
    failure << 'Edit button not enabled' unless row1.find_element(:class, 'fa-edit').enabled?
    failure << 'Delete button not enabled' unless row1.find_element(:class, 'fa-times-circle').enabled?

    assert_empty failure
  end

  def test_admin_publish_video
    # now check the video publish page as admin
    Video.impersonate(@recruit_email)
    Video.goto_publish
    Video.activate_first_row_of_new_video
    check_uploaded_video_table
    check_publish_video_table
    
    # publish it
    Video.publish_video(@file_name)
    
    # now check if the published video shows up in the athlete's profile
    # giving 300 seconds grace period
    Video.goto_preview_profile
    Timeout::timeout(180) {
      loop do
        begin
          @thumbnail = @browser.find_element(:class, 'thumbnail')
        rescue => e
          @browser.navigate.refresh; retry
        end

        break if @thumbnail
      end
    }

    assert @thumbnail.enabled?, 'Video thumbnail not clickable'
  end
end
