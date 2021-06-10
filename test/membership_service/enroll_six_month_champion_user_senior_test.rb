# encoding: utf-8
require_relative '../test_helper'

# TS-41: MS Regression
# UI Test: Enroll as a Champion User - Senior
class EnrollSixmonthChampionSeniorTest < Common
  def setup
    super

    enroll_yr = 'senior'
    @package = 'champion'
    @clientrms = Default.env_config['clientrms']

    _post, post_body = RecruitAPI.new(enroll_yr).ppost
    recruit_email = post_body[:recruit][:athlete_email]

    MSAdmin.setup(@browser)

    UIActions.user_login(recruit_email)
    MSTestTemplate.setup(@browser, recruit_email, @package)
  end

  def teardown
    super
  end

  def select_six_month_payment
    @browser.element('data-payment-plan': 'Champion:6').click
    sleep 2
  end

  def check_membership_cost
    @membership_cost = @browser.elements('data-test-id': 'payment-plan-cell__total-payment')[0].text.to_i
  end

  def define_payments
    @expect_first_pymt = (@membership_cost / 6)
    @expect_remain_balance = @membership_cost - @expect_first_pymt
  end

  def get_expectations
    [@expect_first_pymt, @expect_remain_balance]
  end

  def accept_agreement
    @browser.element(text: 'I Accept').click
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

    assert_equal expected_list.sort, ui_list.sort, 'Membership features NOT matching what is expected'
  end

  def check_displayed_payment_info
    actual_first_pymt, actual_remain_balance, actual_package = MSTestTemplate.get_ui_payments
    expect_first_pymt, expect_remain_balance = get_expectations

    # compare
    assert_equal expect_first_pymt, actual_first_pymt, 'Incorrect first payment shown'
    assert_equal expect_remain_balance, actual_remain_balance, 'Incorrect remaining balance shown'
    assert_equal @package, actual_package, 'Incorrect premium package shown'
  end

  def check_redirected_to_welcome_workshop
    # this check is only for premium enrollment - PREM-4933
    current_url = @browser.url
    failure_msg = "User is not redirected to Welcome Workshop- current url is #{current_url}"
    assert_includes current_url, 'education/search_classes?title=welcome+workshop', failure_msg
  end

  def test_enroll_six_month_champion_senior
    MSSetup.set_password
    MSSetup.goto_offerings
    sleep 2
    MSSetup.goto_offerings
    MSSetup.open_payment_plan

    select_six_month_payment
    check_membership_cost
    define_payments
    get_expectations
    MSProcess.checkout
    accept_agreement

    MSFinish.setup_billing_enroll_now

    check_redirected_to_welcome_workshop

    goto_membership_info
    check_membership_features

    goto_payments
    check_displayed_payment_info
  end
end
