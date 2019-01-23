# encoding: utf-8
require_relative '../test_helper'

# TS-73: POS Regression
# UI Test: Enroll using ACH as Payment (Any Membership)
class EnrollUsingACHPaymentTest < Common
  def setup
    super

    # add a new junior recruit, get back his email address
    @package = %w(champion elite).sample
    _post, post_body = RecruitAPI.new.ppost
    @recruit_email = post_body[:recruit][:athlete_email]

    # while process through the premium purchase process
    # also calculate expected membership and 1st payment
    add_premium
  end

  def teardown
    super
  end

  def add_premium
    MSSetup.setup(@browser)
    MSSetup.set_password(@recruit_email)
    MSSetup.make_commitment
    MSSetup.choose_a_package(@package)

    # choose 6 months payment plan as default
    # get back full price for membership calculation
    full_price = MSSetup.choose_payment_plan
    MSSetup.setup_billing(true) # ach = true

    @membership = MSSetup.calculate(full_price, 6)
    @expect_first_pymt = (@membership / 6)
    UIActions.clear_cookies
  end

  def test_enroll_use_ACH_payment
    expect_remain_balance = @membership - @expect_first_pymt

    UIActions.user_login(@recruit_email)
    @browser.element(:class, 'fa-angle-down').click
    @browser.element(:id, 'secondary-nav-menu').link(:text, 'Payments').click

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
