# encoding: utf-8
require_relative '../test_helper'

# TS-448: MS Regression
# Enroll a client in random membership using 18 month payment plan
# (excluding senior grad class)
class EnrollWith18MoPlanTest < Common
  def setup
    super

    enroll_yr = %w[freshman sophomore].sample
    @package = %w[elite mvp].sample # not applicable for champion
    @clientrms = Default.env_config['clientrms']

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

  def goto_membership_info
    @browser.goto(@clientrms['base_url']+ @clientrms['membership_info'])
  end

  def goto_payments
    @browser.goto(@clientrms['base_url']+ @clientrms['payments_page'])
  end

  def check_membership_features
    ui_list = MSTestTemplate.get_UI_features_list
    membership_service = Default.static_info['membership_service']
    expected_list = is_mvp_baseball ? membership_service['mvp_baseball_features'] : membership_service["#{@package}_features"]

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

  def check_redirected_to_welcome_workshop
    # this check is only for premium enrollment - PREM-4933
    current_url = @browser.url
    failure_msg = "User is not redirected to Welcome Workshop- current url is #{current_url}"
    assert_includes current_url, 'education/search_classes?title=welcome+workshop', failure_msg
  end

  def test_enroll_champion_sophomore
    MSTestTemplate.get_enrolled

    check_redirected_to_welcome_workshop

    goto_membership_info
    check_membership_features

    goto_payments
    check_displayed_payment_info
  end
end
