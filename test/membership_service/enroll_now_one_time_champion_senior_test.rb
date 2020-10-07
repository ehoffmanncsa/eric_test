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
    MSTestTemplate.setup(@browser, recruit_email, @package)
  end

  def teardown
    super
  end

  def check_membership_cost
    total = @browser.elements(class: ['enroll-now-card__price', 'enroll-now-card__price--total'])[6].text
    @membership_cost = total.gsub!(/[^0-9|\.]/, '').to_i
  end

  def select_one_time_payment
    @browser.element(id: '1').click
  end

  def select_elite
    @browser.element('data-offering-id': '9', 'data-payment-plan-id': '1').click
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

    MSAdmin.update_point_of_sale_event(@posclient_id)
    sleep 1
    MSSetup.goto_offerings

    select_one_time_payment
    check_membership_cost
    select_elite
    accept_agreement

    MSFinish.setup_billing_enroll_now

    goto_membership_info
    check_membership_features

    goto_payments
    check_displayed_payment_info
    check_displayed_payment_paid_in_full
  end
end
