# encoding: utf-8
require_relative '../test_helper'

# TS-55: POS Regression
# UI Test: Enroll as a Elite User - Senior
class EnrollEliteSeniorTest < Common
  def setup
    super

    @enroll_yr = 'senior'; @package = 'elite'
    _post, post_body = RecruitAPI.new(@enroll_yr).ppost
    @recruit_email = post_body[:recruit][:athlete_email]
  end

  def teardown
    super
  end

  def add_elite_senior
    MSSetup.setup(@browser)
    MSSetup.set_password(@recruit_email)
    MSSetup.make_commitment
    MSSetup.choose_a_package(@package)
    MSSetup.check_enrollment_discount_calculate(@enroll_yr)

    # choose 6 months payment plan as default
    # get back full price for membership calculation
    full_price = MSSetup.choose_payment_plan
    MSSetup.setup_billing

    @membership = MSSetup.calculate(full_price, 6)
    @expect_first_pymt = (@membership / 6)
  end

  def goto_payments
    clientrms = Default.env_config['clientrms']
    @browser.goto(clientrms['base_url']+ clientrms['payments_page'])
  end

  def test_enroll_elite_senior
    add_elite_senior
    goto_payments

    expect_remain_balance = @membership - @expect_first_pymt

    boxes = @browser.elements(:css, 'div.column.third').to_a
    elem = boxes[2].elements(:class, 'text--size-small').to_a
    actual_first_pymt = elem[0].text.gsub!(/[^0-9|\.]/, '').to_i
    actual_remain_balance = boxes[2].element(:class, 'primary').text.gsub!(/[^0-9|\.]/, '').to_i
    actual_package = elem[1].text.split(' ')[1].downcase

    assert_equal @expect_first_pymt, actual_first_pymt, 'Incorrect first payment shown'
    assert_equal expect_remain_balance, actual_remain_balance, 'Incorrect remaining balance shown'
    assert_equal @package, actual_package, 'Incorrect premium package shown'
  end
end
