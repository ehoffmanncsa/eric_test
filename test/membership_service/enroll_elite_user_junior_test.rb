# encoding: utf-8
require_relative '../test_helper'

# TS-56: MS Regression
# UI Test: Enroll as a Elite User - Junior
class EnrollEliteJuniorTest < Common
  def setup
    super

    enroll_yr = 'junior'
    @package = 'elite'
    @clientrms = Default.env_config['clientrms']

    _post, post_body = RecruitAPI.new(enroll_yr).ppost
    recruit_email = post_body[:recruit][:athlete_email]

    UIActions.user_login(recruit_email)
    MSTestTemplate.setup(@browser, recruit_email, @package)
  end

  def teardown
    super
  end

  def goto_membership_info
    @browser.goto(@clientrms['base_url']+ @clientrms['membership_info'])
  end

  def goto_payments
    @browser.goto(@clientrms['base_url']+ @clientrms['payments_page'])
  end

  def check_membership_features
    ui_list = MSTestTemplate.get_UI_features_list
    expected_list = Default.static_info['membership_service']['elite_features']

    assert_equal expected_list.sort, ui_list.sort, 'Membership features NOT matching what is expected'
  end

  def check_displayed_payment_info
    actual_first_pymt, actual_remain_balance, actual_package = MSTestTemplate.get_ui_payments
    expect_first_pymt, expect_remain_balance = MSTestTemplate.get_expectations

    # compare
    assert_equal expect_first_pymt, actual_first_pymt, 'Incorrect first payment shown'
    assert_equal expect_remain_balance, actual_remain_balance, 'Incorrect remaining balance shown'
    assert_equal @package, actual_package, 'Incorrect premium package shown'
  end

  def check_redirected_to_coachsession
    # this check is only for premium enrollment - SALES-1427
    current_url = @browser.url
    failure_msg = "User is not redirected to coaching session - current url is #{current_url}"
    assert_includes current_url, 'coaching_session_requests/new', failure_msg
  end

  def test_enroll_elite_junior
    MSTestTemplate.get_enrolled

    check_redirected_to_coachsession

    goto_membership_info
    check_membership_features

    goto_payments
    check_displayed_payment_info
  end
end
