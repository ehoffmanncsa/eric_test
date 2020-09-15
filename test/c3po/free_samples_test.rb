# frozen_string_literal: true

require_relative '../test_helper'

# Regression
# UI Test will verify free user samples for Coach Activity Report, Top Matches, Message Center and Snapshot
class FreeSampleTest < Common
  def setup
    super
    email = 'ncsa.automation+4044986a@gmail.com'
    C3PO.setup(@browser)
    UIActions.user_login(email, 'ncsa1333')
  end

  def teardown
    super
  end

  def open_sample_report_car
    @browser.link(text: 'See a sample report').click
    sleep 4
  end

  def verify_sample_report_car
    failure = []
    failure << 'Coach Activity Report sample is not displaying' unless @browser.html.include? 'Dartmouth College'
    assert_empty failure
  end

  def verify_sample_top_matches
    failure = []
    failure << 'Top Matches sample is not displaying' unless @browser.html.include? 'Sample Top Matches'
    assert_empty failure
  end

  def view_message_center_sample
    @browser.element(class: 'button--primary').click
    sleep 3
  end

  def verify_view_sample_message_center_button
    failure = []
    unless @browser.html.include? 'View Sample Message Center'
      failure << 'Message Center Sample button is not displaying'
    end
    assert_empty failure
  end

  def verify_sample_report_message_center
    failure = []
    unless @browser.html.include? 'Hi Student, can you send me your 40yrd dash timing.'
      failure << 'Message Center sample is not displaying'
    end
    assert_empty failure
  end

  def click_college_search
    @browser.element(id: 'csm_submit_button_top').click
    sleep 3
  end

  def click_snapshot_question_mark
    @browser.element(class: %w[free snapshot_link tool]).click
    sleep 5
  end

  def verify_sample_snapshot
    failure = []
    unless @browser.html.include? 'Discover Your Top Schools as a Premium NCSA Member!'
      failure << 'Snapshot Sample is not displaying'
    end
    assert_empty failure
  end

  def sign_out
    clientrms = Default.env_config['clientrms']
    url = clientrms['base_url'] + clientrms['dashboard']
    @browser.goto url

    C3PO.sign_out
  end

  def test_free_samples
    UIActions.close_supercharge
    UIActions.goto_my_colleges
    open_sample_report_car
    verify_sample_report_car
    UIActions.goto_top_matches
    verify_sample_top_matches
    C3PO.goto_message_center
    view_message_center_sample
    sleep 2
    verify_view_sample_message_center_button
    sleep 2
    verify_sample_report_message_center
    UIActions.goto_find_colleges
    click_college_search
    click_snapshot_question_mark
    verify_sample_snapshot
    sign_out
  end
end
