# encoding: utf-8
require_relative '../test_helper'

# TS-421: MS Regression
# UI Test
# This script is to apply all exisiting discount codes
# in offerings page using a static athlete turkeytom@yopmail.com
# i.e. this athlete needs to exist in any environment this test runs in

class ApplyDiscountOnOfferingsPage < Common
  def setup
    super

    UIActions.user_login('turkeytom@yopmail.com')
    @discount_codes = Default.static_info['ncsa_discount_code']

    MSSetup.setup(@browser)
    MSPricing.setup(@browser, nil, true)
    MSProcess.setup(@browser)
  end

  def teardown
    super
  end

  def base_steps
    MSSetup.goto_offerings
    MSSetup.open_payment_plan
    MSSetup.open_discount_box
  end

  def check_on_prices(original_prices, discount_code)
    failure = []
    i = 0

    %w[champion elite mvp].each do |package|
      original_price = original_prices[i]
      discounted_price = MSPricing.collect_prices(package)

      calculated_prices = []
      months = [1, 6, 12, 18]
      months.each do |months|
        break if(package == 'champion' && months == 18)
        calculated_prices << MSPricing.calculate(original_price, months, discount_code)
      end

      calculated_prices.zip(discounted_price).map do |c, d|
        msg = "Calculated price #{c} vs Shown price #{d} - Code #{discount_code} - Package #{package}"
        failure << msg unless c.eql? d
      end

      i += 1
    end

    MSProcess.remove_discount

    failure
  end


  def test_apply_discount_on_offerings_page
    base_steps

    failure = []
    original_prices = MSPricing.one_month_plan_prices

    @discount_codes.each do |code, _rate|
      MSProcess.apply_discount(code)
      MSSetup.reveal_18_mo_plan; sleep 2
      fail_message = check_on_prices(original_prices, code)
      failure << fail_message unless fail_message.empty?
      failure.flatten!
    end

    assert_empty failure
  end
end
