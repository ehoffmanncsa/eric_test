# frozen_string_literal: true

require_relative '../test_helper'

# Regression
# UI Test will verify free user samples for Coach Activity Report, Top Matches, Message Center and Snapshot
class EnrollNowTest < Common
  def setup
    super
    skip #skipping until menu enroll button not displaying in firefox is resolved
    email = 'ncsa.automation+6380ea10@gmail.com'
    C3PO.setup(@browser)
    UIActions.user_login(email, 'ncsa1333')
  end

  def teardown
    super
  end

  def click_enroll
    @browser.link(text: 'Enroll').click
    sleep 4
  end

  def verify_enrollment_form
    failure = []
    failure << 'Enrollment from is not displaying' unless @browser.html.include? 'Choose Payment Plan'
    assert_empty failure
  end

  def select_from_menu
    @browser.element(class: 'fa-angle-down').click
    navbar = @browser.element(id: 'secondary-nav-menu')
    navbar.link(text: 'Request an Assessment').click
  end

  def sign_out
    clientrms = Default.env_config['clientrms']
    url = clientrms['base_url'] + clientrms['dashboard']
    @browser.goto url

    C3PO.sign_out
  end

  def test_enroll
    UIActions.close_supercharge
    click_enroll
    verify_enrollment_form
    UIActions.goto_dashboard
    select_from_menu
    click_enroll
    verify_enrollment_form
    sign_out
  end
end
