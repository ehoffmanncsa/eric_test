# frozen_string_literal: true

require_relative '../test_helper'

# MS Regression
# UI Test: Enroll Now as a MVP User - sophomore, 18 month payment plan
class EnrollNowEighteenMonthMvpSophomoreTest < Common
  def setup
    super

    enroll_yr = 'sophomore'
    @package = 'mvp'
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

  def is_baseball
    @sport_id == '17706'
  end

  def select_eighteen_month_payment
    @browser.element('data-test-id': 'plan-month-button-18').click
    sleep 2
  end

  def check_membership_cost
    @membership_cost = @browser.element('data-test-id': 'package-card-total-MVP').text
    if @membership_cost.nil?
       @membership_cost = 0
    else
      @membership_cost.gsub!(/[^0-9]/, '').to_i
    end
  end

  def define_payments
    @expect_first_pymt = (@membership_cost.to_i / 18)
    @expect_remain_balance = @membership_cost.to_i - @expect_first_pymt
  end

  def get_expectations
    [@expect_first_pymt, @expect_remain_balance]
  end

  def select_mvp
    @browser.element('data-test-id': 'package-card-select-MVP').click
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

    membership_service = Default.static_info['membership_service']
    expected_list = is_baseball ? membership_service['mvp_baseball_features'] : membership_service['mvp_features']

    assert_equal expected_list.sort, ui_list.sort, 'Membership features NOT matching what is expected'
  ends

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

  def test_enroll_now_eighteen_month_mvp_sophomore
    MSSetup.set_password
    MSSetup.goto_offerings
    sleep 2
    MSAdmin.update_point_of_sale_event(@posclient_id)
    sleep 2
    MSSetup.goto_offerings

    sleep 3
    select_eighteen_month_payment
    check_membership_cost
    define_payments
    get_expectations
    select_mvp
    sleep 2
    accept_agreement

    MSFinish.setup_billing_enroll_now

    check_redirected_to_welcome_workshop

    goto_membership_info
    check_membership_features

    goto_payments
    check_displayed_payment_info
  end
end
