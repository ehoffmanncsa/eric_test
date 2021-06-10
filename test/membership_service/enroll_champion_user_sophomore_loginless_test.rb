# encoding: utf-8
require_relative '../test_helper'

# TS-52: MS Regression
# UI Test: Enroll as a Champion User - Sophomore
class EnrollChampionSophomoreLoginlessTest < Common
  def setup
    super

    enroll_yr = 'sophomore'
    @package = 'champion'
    @clientrms = Default.env_config['clientrms']

    post, post_body = RecruitAPI.new(enroll_yr).ppost
    @client_id = post["client_id"]
    @recruit_email = post_body[:recruit][:athlete_email]

    UIActions.user_login(@recruit_email)
    MSTestTemplate.setup(@browser, @recruit_email, @package)
  end

  def teardown
    super
  end

  def token
    Base64.encode64(@client_id.to_s)
  end

  def goto_offerings
    clientrms = Default.env_config['clientrms']
    @browser.goto(clientrms['base_url'] + clientrms['offerings_page'] + "?token=#{token}")

    if (@browser.url.include? 'commitment')
      make_commitment
    end

    Watir::Wait.until { @browser.element(id: 'start-cobrowse-random-key').present? }
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

  def sign_out
    clientrms = Default.env_config['clientrms']
    @browser.goto(clientrms['base_url'] + clientrms['logout_page'])
    Watir::Wait.until { @browser.element(id: 'user_account_login').present? }
  end

  def check_redirected_to_login
    current_url = @browser.url
    failure_msg = "User is not redirected to sign in - current url is #{current_url}"
    assert_includes current_url, 'user_accounts/sign_in?redirect_to=%2Fclientrms%2Faccounts%3Finitial_enrollment%3Dtrue', failure_msg
  end

  def login_again
    @browser.text_field(id: 'user_account_login').set @recruit_email
    @browser.text_field(id: 'user_account_password').set 'ncsa1333'
    @browser.button(name: 'commit').click; sleep 1

    # waiting for the right page title
    begin
      Watir::Wait.until { !@browser.title.match(/Student-Athlete Sign In/) }
      sleep 1
    rescue => e
      puts e; @browser.close
    end
  end

  def test_enroll_champion_sophomore_loginless
    MSSetup.set_password
    sign_out
    goto_offerings
    MSTestTemplate.open_payment_plan
    MSTestTemplate.check_on_prices
    MSTestTemplate.define_expectations
    MSTestTemplate.enroll(ach: false, checkout_cart: false)
    check_redirected_to_login
    login_again
    check_redirected_to_welcome_workshop

    goto_membership_info
    check_membership_features

    goto_payments
    check_displayed_payment_info
  end
end
