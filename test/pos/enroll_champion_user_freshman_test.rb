# encoding: utf-8
require_relative '../test_helper'

# TS-54: POS Regression
# UI Test: Enroll as a Champion User - Freshman
class EnrollChampionFreshmanTest < Common
  def setup
    super

    # add a new freshman recruit, get back his email address
    @enroll_yr = 'freshman'
    @package = 'champion'

    _post, post_body = RecruitAPI.new(@enroll_yr).ppost
    @recruit_email = post_body[:recruit][:athlete_email]
  end

  def teardown
    super
  end

  def add_champion_freshman
    POSSetup.setup(@browser)
    POSSetup.set_password(@recruit_email)
    POSSetup.make_commitment
    POSSetup.choose_a_package(@package)
    POSSetup.check_enrollment_discount_calculate(@enroll_yr)

    # choose 6 months payment plan as default
    # get back full price for membership calculation
    full_price = POSSetup.choose_payment_plan
    POSSetup.setup_billing

    @membership = POSSetup.calculate(full_price, 6)
    @expect_first_pymt = (@membership / 6)
  end

  def goto_payments
    @browser.goto 'https://qa.ncsasports.org/clientrms/finances'
  end

  def test_enroll_champion_freshman
    add_champion_freshman
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
