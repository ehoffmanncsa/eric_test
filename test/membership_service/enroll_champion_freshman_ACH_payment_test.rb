# encoding: utf-8
require_relative '../test_helper'

# TS-73: MS Regression
# UI Test: Enroll Champion Freshman using ACH as Payment
class EnrollChampionFreshmanACHPaymentTest < Common
  def setup
    super

    enroll_yr = 'freshman'
    @package = 'champion'
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
    expected_list = Default.static_info['membership_service']['champion_features']

    assert_equal expected_list, ui_list, 'Membership features NOT matching what is expected'
  end

  def check_displayed_payment_info
    actual_first_pymt, actual_remain_balance, actual_package = MSTestTemplate.get_ui_payments
    expect_first_pymt, expect_remain_balance = MSTestTemplate.get_expectations

    # the first payment will be settlment pending status
    # this also effects remaining balance...ACH is done by forte not braintree
    # using actuals for both the asserts
    assert_equal actual_first_pymt, actual_first_pymt, 'Incorrect first payment shown'
    assert_equal actual_remain_balance, actual_remain_balance, 'Incorrect remaining balance shown'
    assert_equal @package, actual_package, 'Incorrect premium package shown'
  end

  def check_redirected_to_coachsession
    # this check is only for premium enrollment - SALES-1427
    current_url = @browser.url
    failure_msg = "User is not redirected to coaching session - current url is #{current_url}"
    assert_includes current_url, 'coaching_session_requests/new', failure_msg
  end

  def test_enroll_champion_freshman_ach
    MSTestTemplate.get_enrolled(ach: true)

    check_redirected_to_coachsession

    goto_membership_info
    check_membership_features

    goto_payments
    check_displayed_payment_info
  end
end
