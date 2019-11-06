# encoding: utf-8
require_relative '../test_helper'
#TS-564
=begin
Here we are verifying video updated date  displayed on activity page by comparing it with video updated date
 on Athlete detail page.'
=end

class VerifyActivityDataTest < Common
  def setup
    super
    TED.setup(@browser)
  end

  def test_compare_video_updated_date
    UIActions.ted_login('coacheric.ted@gmail.com', 'ncsa')
    url = Default.env_config['ted']['base_url'] + 'activity'
    @browser.goto url
    Watir::Wait.until { UIActions.find_by_test_id("athlete-activity").present? }

    video_updated_date = ""
    athlete_row, athlete_row_index = @browser.elements(class: "athlete-activity-row").each_with_index.find do |row, i|
      video_updated_date = UIActions.find_by_test_id("athlete-activity-row-#{i}-cell-videoUpdatedDate").text
      video_updated_date != "-"
    end

    athlete_row.element.click
    Watir::Wait.until { @browser.element(class: "athlete-profile").present? }

    video_box_text = @browser.element(class: "toggleVideo-js").text
    assert_includes video_box_text, video_updated_date, "Activity Page: video updated data is inconsistent between activity page and athlete detail page"
  end
end
