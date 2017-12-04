# encoding: utf-8
require_relative '../test_helper'

# TS-56: POS Regression
# UI Test: Enroll as a Elite User - Junior
class EnrollEliteJuniorTest < Minitest::Test
  def setup
    @ui = LocalUI.new(true)
    @browser = @ui.driver

    # add a new junior recruit, get back his email address
    _resp, _post, post_body = RecruitAPI.new('junior').ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    @package = 'elite'
  end

  def teardown
    @browser.close
  end

  def test_enroll_elite_junior
    POSSetup.setup(@ui)
    membership, expect_first_pymt = POSSetup.buy_package(@recruit_email, @package)
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
    assert_equal @package, actual_package
  end
end
