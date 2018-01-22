# encoding: utf-8
require_relative '../test_helper'

# TS-55: POS Regression
# UI Test: Enroll as a Elite User - Senior
class EnrollEliteSeniorTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)

    # add a new senior recruit, get back his email address
    @enroll_yr = 'senior'; @package = 'elite'
    _post, post_body = RecruitAPI.new(@enroll_yr).ppost
    @recruit_email = post_body[:recruit][:athlete_email]

    # while process through the premium purchase process
    # also calculate expected membership and 1st payment
    add_elite_senior
  end

  def teardown
    @browser.close
  end

  def add_elite_senior
    POSSetup.setup(@browser)
    POSSetup.set_password(@recruit_email)
    POSSetup.make_commitment
    POSSetup.choose_a_package(@package)
    POSSetup.check_discount_calculate(@enroll_yr)

    # choose 6 months payment plan as default
    # get back full price for membership calculation
    full_price = POSSetup.choose_payment_plan
    POSSetup.setup_billing

    @membership = POSSetup.calculate(full_price, 6)
    @expect_first_pymt = (@membership / 6)
    UIActions.clear_cookies
  end

  def test_enroll_elite_senior
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
