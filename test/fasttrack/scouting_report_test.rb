# frozen_string_literal: true

require_relative '../test_helper'

# MS Regression
# UI Test: Scouting Report Test
class ScoutingReportTest < Common
  def setup
    super
    Fasttrack.setup(@browser)
    ScoutReport.setup(@browser)
    MSAdmin.setup(@browser)
    C3PO.setup(@browser)
    @client_id = 5795323
  end

  def teardown
    super
  end

  def test_scouting_report
    do_preps
    C3PO.goto_top_matches
    sleep 2
    C3PO.open_scouting_report
    sleep 5
    verify_scouting_report_data
  end

  private

  def fill_out_scouting_report
    ScoutReport.enter_video_comments
    ScoutReport.save_video_comments
    ScoutReport.select_dropdowns
    ScoutReport.enter_key_skills_comments
    ScoutReport.save_key_skills_comments
    enter_coach_pick_notes
    ScoutReport.save_coach_picks
    enter_coach_talking_point
    ScoutReport.save_marketing_plans
    ScoutReport.enter_communications_comments
    ScoutReport.save_communication_timeline
    ScoutReport.enter_email_subject
    ScoutReport.enter_email_body
    ScoutReport.save_email_template
    ScoutReport.publish_report
    ScoutReport.preview_report
  end

  def do_preps
    Fasttrack.delete_scouting_report_data
    UIActions.fasttrack_login
    C3PO.impersonate(@client_id)
    sleep 2
    C3PO.open_evaluation_section
    sleep 2
    C3PO.open_evaluation_report
    sleep 2
    @id = Fasttrack.retrieve_current_scouting_report_id.to_s
    @target_school_ids = Fasttrack.retrieve_target_school_ids_for(@id)
    @marketing_plans_ids = Fasttrack.retrieve_marketing_plans_ids_for(@id)
    fill_out_scouting_report
  end

  def enter_coach_talking_point
    @marketing_plans_ids.each do |marketing_plans_id|
      @browser.element(id: "scouting_report_marketing_plan_#{marketing_plans_id}").send_keys MakeRandom.lorem
    end
  end

  def enter_coach_pick_notes
    @target_school_ids.each do |target_school_id|
      @browser.textarea(id: "scouting_report_target_school_#{target_school_id}[note]").send_keys MakeRandom.lorem
    end
  end

  def verify_scouting_report_data
    failure = []
    failure << 'Video clip comments are not displaying' unless @browser.html.include? 'Coach Eric Video comments'
    failure << 'Key Skills comments are not displaying' unless @browser.html.include? 'Coach Eric Key Skills comments'
    failure << 'Coach Pick comments are not displaying' unless @browser.html.include? 'Coach Picks'
    unless @browser.html.include? 'Coach Eric Communication Timeline comments'
      failure << 'Communication Timeline comments are not displaying'
    end
    unless @browser.html.include? 'Introduction Email Template'
      failure << 'Email template subject and body are not displaying'
    end
    assert_empty failure
  end
end
