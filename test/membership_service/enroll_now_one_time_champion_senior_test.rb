# frozen_string_literal: true

require_relative '../test_helper'

# MS Regression
# UI Test: Enroll Now as a Champion User - senior, one-time payment plan
# on-time payment does not get a welcome call
class EnrollNowOneTimeChampionSeniorTest < Common
  def setup
    super

    enroll_yr = 'senior'
    @package = 'champion'
    @clientrms = Default.env_config['clientrms']

    post, post_body = RecruitAPI.new(enroll_yr).ppost
    recruit_email = post_body[:recruit][:athlete_email]
    @posclient_id = post['client_id']
    MSAdmin.setup(@browser)

    UIActions.user_login(recruit_email)
    sleep 2
    MSTestTemplate.setup(@browser, recruit_email, @package)
  end

  def teardown
    super
  end

  def check_membership_cost
    @membership_cost = @browser.element('data-test-id': 'package-card-total-Champion').text
    return @membership_cost.gsub!(/[^0-9]/, '').to_i unless @membership_cost.nil?
  end

  def select_one_month_payment
    @browser.element('data-test-id': 'plan-month-button-1').click
    sleep 2
  end

  def select_champion
    @browser.element('data-test-id': 'package-card-select-Champion').click
    sleep 2
  end

  def accept_agreement
    @browser.element(text: 'I Accept').click
  end

  def check_redirected_to_welcome_workshop
    # this check is only for premium enrollment - PREM-4933
    current_url = @browser.url
    failure_msg = "User is not redirected to Welcome Workshop- current url is #{current_url}"
    assert_includes current_url, 'education/search_classes?title=welcome+workshop', failure_msg
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
    failure = []
    failure << 'One time price is not displaying' unless @browser.html.include? "#{@membership_cost}"
    assert_empty failure
  end

  def check_displayed_payment_paid_in_full
    failure = []
    failure << 'Paid in full not displaying' unless @browser.html.include? "Paid in full"
    assert_empty failure
  end

  def test_enroll_now_one_time_champion_senior
    MSSetup.set_password
    MSSetup.goto_offerings
    sleep 2
    MSAdmin.update_point_of_sale_event(@posclient_id)
    sleep 2
    MSSetup.goto_offerings

    select_one_month_payment
    check_membership_cost
    select_champion
    accept_agreement

    MSFinish.setup_billing_enroll_now

    check_redirected_to_welcome_workshop

    goto_membership_info
    check_membership_features

    goto_payments
    check_displayed_payment_info
    check_displayed_payment_paid_in_full
  end
end
