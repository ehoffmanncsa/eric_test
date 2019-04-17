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
    MSPricing.setup(@browser)
    MSProcess.setup(@browser)
  end

  def teardown
    super
  end

  def open_discount
    @browser.div(:class, ['fa-swoosh', 'show-discount-js']).click
  end

  def base_steps
    MSSetup.goto_offerings
    MSSetup.open_payment_plan
    open_discount
  end

  def cells
    MSPricing.gather_all_payment_plan_cells
  end

  def champion
    #               1mo       6mo       12mo
    ['champion', cells[9], cells[6], cells[3]]
  end

  def elite
    ['elite', cells[10], cells[7], cells[4]]
  end

  def mvp
    ['mvp', cells[11], cells[8], cells[5]]
  end

  def collect_prices(package)
    prices = []

    fullprice_cell = package[1]
    monthly_cells = package[2 .. 3]

    prices << fullprice_cell.element(:class, 'full').text.gsub(/\D/, '').to_i
    monthly_cells.each do |cell|
      prices << cell.element(:class, 'small').text.gsub(/\D/, '').to_i
    end

    prices
  end

  def check_on_prices(original_prices, discount_code)
    failure = []
    i = 0

    [champion, elite, mvp].each do |package|
      original_price = original_prices[i]
      discounted_price = collect_prices(package)

      calculated_prices = []
      months = [1, 6, 12] # add 18 here when that feature available and pop last 2 if senior
      months.each do |months|
        calculated_prices << MSPricing.calculate(original_price, months, discount_code)
      end

      calculated_prices.zip(discounted_price).map do |c, d|
        msg = "Package #{package[0]}, Code #{discount_code} - Actual: #{d} vs Expected: #{c}"
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

    @discount_codes.each do |discount_code, _rate|
      MSProcess.apply_discount_offerings(discount_code)
      fail_message = check_on_prices(original_prices, discount_code)
      failure << fail_message unless fail_message.empty?
      failure.flatten!
    end

    assert_empty failure
  end
end
