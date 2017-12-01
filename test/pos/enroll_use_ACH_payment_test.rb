# encoding: utf-8
require_relative '../test_helper'

# TS-73: POS Regression
# UI Test: Enroll using ACH as Payment (Any Membership)
class EnrollUsingACHPaymentTest < Minitest::Test
  def setup
    @ui = LocalUI.new(true)
    @browser = @ui.driver

    # add a new recruit random, get back his email address and username
    _resp, _post, @username = RecruitAPI.new.ppost
    @recruit_email = "#{@username}@ncsasports.org"
  end

  def teardown
    @browser.close
  end

  def test_enroll_use_ACH_payment
    # pick a random package, cant pick mvp right now because discount calculation is off
    package = %w(champion elite).sample

    POSSetup.setup(@ui)
    membership, expect_first_pymt = POSSetup.buy_with_ACH_payment(@recruit_email, package)
    expect_remain_balance = membership - expect_first_pymt

    @ui.user_login(@recruit_email)
    @browser.find_element(:class, 'fa-angle-down').click
    @browser.find_element(:id, 'secondary-nav-menu').find_element(:link_text, 'Payments').click

    @ui.wait(30) { @browser.find_elements(:css, 'div.column.third')[2].displayed? }
    box = @browser.find_elements(:css, 'div.column.third')[2]

    actual_first_pymt = box.find_elements(:class, 'text--size-small')[0].text.gsub!(/[^0-9|\.]/, '').to_i
    actual_remain_balance = box.find_element(:class, 'primary').text.gsub!(/[^0-9|\.]/, '').to_i
    actual_package = box.find_elements(:class, 'text--size-small')[1].text.split(' ')[1].downcase
    
    assert_equal expect_first_pymt, actual_first_pymt
    assert_equal expect_remain_balance, actual_remain_balance
    assert_equal package, actual_package
  end
end
