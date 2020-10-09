# frozen_string_literal: true

require_relative '../test_helper'

# MS Regression
# UI Test: Enroll Now as a Champion User - freshman, 6 month payment plan
class EnrollNowSixMonthChampionFreshmanTest < Common
  def setup
    super

    enroll_yr = 'freshman'
    @package = 'champion'
    @clientrms = Default.env_config['clientrms']

    post, post_body = RecruitAPI.new(enroll_yr).ppost
    recruit_email = post_body[:recruit][:athlete_email]
    @posclient_id = post['client_id']
    MSAdmin.setup(@browser)

    UIActions.user_login(recruit_email)
    MSTestTemplate.setup(@browser, recruit_email, @package)
  end

  def teardown
    super
  end

  def check_membership_cost
    total = @browser.elements(class: ['enroll-now-card__price', 'enroll-now-card__price--total'])[6].text
    @membership_cost = total.gsub!(/[^0-9|\.]/, '').to_i
   end

  def define_payments
    @expect_first_pymt = (@membership_cost / 6)
    @expect_remain_balance = @membership_cost - @expect_first_pymt
  end

  def get_expectations
    [@expect_first_pymt, @expect_remain_balance]
  end

  def select_6_payments
    @browser.element(id: '6').click
  end

  def select_champion
    @browser.element('data-offering-id': '9', 'data-payment-plan-id': '2').click
  end

  def accept_agreement
    @browser.element(text: 'I Accept').click
  end

  def goto_membership_info
    @browser.goto(@clientrms['base_url'] + @clientrms['membership_info'])
  end

  def goto_payments
    @browser.goto(@clientrms['base_url'] + @clientrms['payments_page'])
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

  def check_redirected_to_coachsession
    # this check is only for premium enrollment - SALES-1427
    current_url = @browser.url
    failure_msg = "User is not redirected to coaching session - current url is #{current_url}"
    assert_includes current_url, 'coaching_session_requests/new', failure_msg
  end

  def test_enroll_now_six_month_champion_freshman
    MSSetup.set_password
    MSSetup.goto_offerings

    MSAdmin.update_point_of_sale_event(@posclient_id)
    sleep 1
    MSSetup.goto_offerings

    select_6_payments
    check_membership_cost
    define_payments
    get_expectations
    select_champion
    accept_agreement

    MSFinish.setup_billing_enroll_now

    check_redirected_to_coachsession

    goto_membership_info
    check_membership_features

    goto_payments
    check_displayed_payment_info
  end
end
