# encoding: utf-8
require_relative '../test_helper'

# TS-448: MS Regression
# Enroll a client in random membership using 18 month payment plan
# (excluding senior grad class)
class EnrollWith18MoPlanTest < Common
  def setup
    super

    enroll_yr = %w[freshman sophomore junior].sample
    @package = %w[elite mvp].sample # not applicable for champion

    _post, post_body = RecruitAPI.new(enroll_yr).ppost
    recruit_email = post_body[:recruit][:athlete_email]
    @sport_id = post_body[:recruit][:sport_id]

    UIActions.user_login(recruit_email)

    MSTestTemplate.setup(@browser, recruit_email, @package, true)
  end

  def teardown
    super
  end

  def is_mvp_baseball
    @sport_id == '17706' && @package == 'mvp'
  end

  def check_membership_features
    ui_list = MSTestTemplate.get_UI_features_list
    membership_service = Default.static_info['membership_service']
    expected_list = is_mvp_baseball ? membership_service['mvp_baseball_features'] : membership_service["#{@package}_features"]

    assert_equal expected_list, ui_list, 'Membership features NOT matching what is expected'
  end

  def goto_payments
    clientrms = Default.env_config['clientrms']
    @browser.goto(clientrms['base_url']+ clientrms['payments_page'])
  end

  def check_displayed_payment_info
    actual_first_pymt, actual_remain_balance, actual_package = MSTestTemplate.get_ui_payments
    expect_first_pymt, expect_remain_balance = MSTestTemplate.get_expectations

    # compare
    assert_equal expect_first_pymt, actual_first_pymt, 'Incorrect first payment shown'
    assert_equal expect_remain_balance, actual_remain_balance, 'Incorrect remaining balance shown'
    assert_equal @package, actual_package, 'Incorrect premium package shown'
  end

  def test_enroll_champion_sophomore
    MSTestTemplate.get_enrolled

    check_membership_features

    goto_payments
    check_displayed_payment_info
  end
end
