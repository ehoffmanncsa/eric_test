# encoding: utf-8
require_relative '../test_helper'

# TS-E1: C3PO Regression
# UI Test: Add TAP Test

class VerifyTAPResultShowUpTest < Common
  def setup
    super

    email = 'ncsa.automation+b20b@gmail.com'
    UIActions.user_login(email, 'ncsa1333')
  end

  def teardown
    super
  end

  private

  def test_tap_result_show_up
    C3PO.goto_tap_results
  end

  def verify_event
    # go to Preview Profile and check event
    subheader = @browser.element(:class, 'subheader')
    subheader.element(:id, 'tap_results_link').click
    @browser.element(:class, 'show-on-profile-checkbox').click; sleep 1
    subheader = @browser.element(:class, 'subheader')
    subheader.element(:id, 'edit_my_information_link').click
    @browser.element(:class, 'button--primary').click; sleep 1

    tap_results = @browser.elements(:class, 'info-category tap-assessment')
    expected_tap = 'TAP ATHLETIC TYPE'
    assert_includes tap_results.first.text, expected_tap
  end

  def remove_tap_data_from_athlete
  end

  def insert_tap_data
  end
end
