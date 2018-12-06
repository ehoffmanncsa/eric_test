# encoding: utf-8
require_relative '../test_helper'

# POS Regression
# This script is to apply all exisiting discount codes
# in offerings page using the below static athlete

class ApplyDiscountOnOfferingsPage < Common
  def setup
    super

    POSSetup.setup(@browser)

    @athlete_email = 'turkeytom@yopmail.com'
    @discount_codes = Default.static_info['ncsa_discount_code']
  end

  def teardown
    super
  end

  def cells
    @browser.elements(:class, ['select-plan', 'js-package-button'])
  end

  def champion
    ['champion', 899, cells[9], cells[3], cells[6]]
  end

  def elite
    ['elite', 1699, cells[10], cells[4], cells[7]]
  end

  def mvp
    ['mvp', 2999, cells[11], cells[5], cells[8]]
  end

  def collect_prices(package)
    prices = []

    fullprice_cell = package[2]
    monthly_cells = package[3 .. 4]

    prices << fullprice_cell.element(:class, 'full').text.gsub(/\D/, '')
    monthly_cells.each do |cell|
      prices << cell.element(:class, 'small').text.gsub(/\D/, '')
    end

    prices
  end

  def calculate_discount(code)
    POSSetup.calculate(full_price, months, code)
  end

  def test_apply_discount_on_offerings_page
    UIActions.user_login(@athlete_email)

    POSSetup.goto_offerings; sleep 2
    POSSetup.open_payment_plan

    # activate discount feature
    @browser.div(:class, ['fa-swoosh', 'show-discount-js']).click

    @discount_codes.each do |code, _rate|
      POSSetup.apply_discount_offerings(code)

      [champion, elite, mvp].each do |package|
        orignal_price = package[1]
        discounted_price = collect_prices(package)

        calculated_prices = []
        months = [1, 6, 12] # add 18 here when that feature available and pop last 2 if senior
        months.each do |months|
          calculated_prices << POSSetup.calculate(orignal_price, months, code)
        end

        failure = []
        calculated_prices.zip(discounted_price).map do |c, d|
          msg = "Package #{package[0]}, Code #{code} - Actual: #{d} vs Expected: #{c}"
          failure << msg unless c.eql? d
        end
      end

      POSSetup.remove_discount
    end
  end
end
