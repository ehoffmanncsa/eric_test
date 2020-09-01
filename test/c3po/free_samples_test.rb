# frozen_string_literal: true

require_relative '../test_helper'

# Regression
# UI Test will verify free user samples for Coach Activity Report, Top Matches and Message Center
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

  def check_sample_report_car
    failure = []
    unless @browser.html.include? 'Dartmouth College'
      failure << 'Sample Report for Coach Activity report is not displaying'
    end
    assert_empty failure
  end

  def check_sample_report_top_matches
    failure = []
    failure << 'Sample Report for Top Matches is not displaying' unless @browser.html.include? 'Sample Top Matches'
    assert_empty failure
  end

  def view_message_center_sample
    @browser.element(class: 'button--primary').click
    sleep 3
  end

  def check_sample_report_message_center
    failure = []
    unless @browser.html.include? 'Hi Student, can you send me your 40yrd dash timing.'
      failure << 'Sample Report for Message Center is not displaying'
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
    check_sample_report_car
    UIActions.goto_top_matches
    check_sample_report_top_matches
    C3PO.goto_message_center
    view_message_center_sample
    check_sample_report_message_center
    sign_out
  end
end
