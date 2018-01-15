# encoding: utf-8
require_relative '../test_helper'

# TS-73: POS Regression
# UI Test: Enroll using ACH as Payment (Any Membership)
class EnrollUsingACHPaymentTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)

    # add a new recruit random, get back his email address
    _post, post_body = RecruitAPI.new.ppost
    @recruit_email = post_body[:recruit][:athlete_email]
  end

  def teardown
    @browser.close
  end

  def test_enroll_use_ACH_payment
    # pick a random package, cant pick mvp right now because discount calculation is off
    package = %w(champion elite).sample

    POSSetup.setup(@browser)
    membership, expect_first_pymt = POSSetup.buy_with_ACH_payment(@recruit_email, package)
    expect_remain_balance = membership - expect_first_pymt

    UIActions.user_login(@recruit_email)
    @browser.element(:class, 'fa-angle-down').click
    @browser.element(:id, 'secondary-nav-menu').link(:text, 'Payments').click

    boxes = @browser.elements(:css, 'div.column.third').to_a
    elem = boxes[2].elements(:class, 'text--size-small').to_a
    actual_first_pymt = elem[0].text.gsub!(/[^0-9|\.]/, '').to_i
    actual_remain_balance = boxes[2].element(:class, 'primary').text.gsub!(/[^0-9|\.]/, '').to_i
    actual_package = elem[1].text.split(' ')[1].downcase
    
    assert_equal expect_first_pymt, actual_first_pymt
    assert_equal expect_remain_balance, actual_remain_balance
    assert_equal package, actual_package
  end
end
