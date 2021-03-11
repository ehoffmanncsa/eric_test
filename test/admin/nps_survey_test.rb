# frozen_string_literal: true

require_relative '../test_helper'

# MS Regression
# UI Test: NPS Survey Test - select a NPS score, enter comments, then
# verify tracking note displays NPS score and comments
class NPSSurveyTest < Common
  def setup
    super
    Fasttrack.setup(@browser)
    ScoutReport.setup(@browser)
    MSAdmin.setup(@browser)
    C3PO.setup(@browser)
    @client_id = 5_800_068
    @comments = MakeRandom.lorem
  end

  def teardown
    super
  end

  def open_nps_survey
    @browser.goto 'https://qa.ncsasports.org/clientrms/nps_survey'
  end

  def nps_survey_rating
    @browser.element(id: 'nps_survey_question1_text_5').click
  end

  def nps_survey_comments
    @browser.element(id: 'nps_survey_question2_text').send_keys @comments
    sleep 2
    @browser.button(value: 'Submit').click
  end

  def nps_tracking_note_show_message
    table = @browser.table(class: %w[l-bln-mg-btm-2 m-tbl tablesorter tn-table])
    latest_note = table.tbody[0].td(index: 3)
    message_title = latest_note.element(text: 'Show Full Message').click
  end

  def verify_nps_survey_comments
    failure = []
    failure << 'NPS rating are not displaying' unless @browser.html.include? 'NPS Score: 5'
    unless @browser.html.include? "NPS Survey Completed, score: 5, score reason: #{@comments}"
      failure << 'NPS comments are not displaying'
    end
    assert_empty failure
  end

  def test_nps_survey
    Fasttrack.delete_nps_tracking_note
    Fasttrack.soft_delete_nps_survey
    UIActions.user_login('testd13c@yopmail.com', 'ncsa1333')
    open_nps_survey
    nps_survey_rating
    nps_survey_comments

    UIActions.fasttrack_login
    C3PO.impersonate(@client_id)
    C3PO.open_tracking_note(@client_id)
    sleep 2
    nps_tracking_note_show_message
    sleep 3
    verify_nps_survey_comments
    sleep 2
  end
end
