# frozen_string_literal: true

require_relative '../test_helper'

# MS Regression
# UI Test: Loginless user will access the Enroll Now offerings page
# from a simulated email link url and purchase a MVP membership, on time payment plan
# After completing purchase, user is prompted to login and is redirected to the Dashboard
class EnrollNowLoginlessOneTimeMVPFreshmanTest < Common
  def setup
    super

    enroll_yr = 'freshman'
    @package = 'mvp'
    @clientrms = Default.env_config['clientrms']

    post, post_body = RecruitAPI.new(enroll_yr).ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    @posclient_id = post['client_id']

    MSAdmin.setup(@browser)

    UIActions.user_login(@recruit_email)
    MSTestTemplate.setup(@browser, @recruit_email, @package)
  end

  def teardown
    super
  end

  def token
    Base64.encode64(@posclient_id.to_s)
  end

  def goto_offerings
    clientrms = Default.env_config['clientrms']
    @browser.goto(clientrms['base_url'] + clientrms['offerings_page'] + "?token=#{token}")
    sleep 3
  end

  def select_one_time_payment
    @browser.element('data-test-id': 'plan-month-button-1').click
    sleep 2
  end

  def check_membership_cost
    # not converting the value to an integer and doing a gsub
    # because payments page includes the comma for amounts over 1,000
    @membership_cost = @browser.element(class: 'js-total-price').text
  end

  def select_mvp
    @browser.element('data-test-id': 'package-card-select-MVP').click
    sleep 3
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
    expected_list = Default.static_info['membership_service']['mvp_features']

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

  def test_enroll_now_one_time_mvp_freshman
    MSSetup.set_password
    sleep 2
    MSSetup.goto_offerings
    sleep 2
    MSAdmin.update_point_of_sale_event(@posclient_id)
    sleep 2
    UIActions.clientrms_sign_out
    sleep 2
    goto_offerings
    sleep 2
    select_one_time_payment
    select_mvp
    sleep 1
    check_membership_cost # get value from the membership/enrollment page where value has the comma
    accept_agreement

    MSFinish.setup_billing_enroll_now
    sleep 2
    UIActions.user_login(@recruit_email, 'ncsa1333')
    sleep 2

    goto_membership_info
    check_membership_features
    goto_payments
    sleep 2
    check_displayed_payment_info
    check_displayed_payment_paid_in_full
  end
end
