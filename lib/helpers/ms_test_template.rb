# encoding: utf-8

# Set up a new lead for POS base 2 conditions: grad year and package type
# choosing and returning 6 payments financing option as default
# that way we can test for remaining balance and first payment made
module MSTestTemplate
  def self.setup(ui_object, recruit_email, package)
    @browser = ui_object
    @recruit_email = recruit_email

    MSSetup.setup(ui_object)
    MSPricing.setup(ui_object, package)
    MSProcess.setup(ui_object)
    MSFinish.setup(ui_object)
  end

  def self.goto_offerings
    MSSetup.set_password(@recruit_email)
    MSSetup.goto_offerings
    MSSetup.open_payment_plan
  end

  def self.check_on_prices
    @prices = MSPricing.collect_prices # respectively [1mo, 6mo, 12mo]

    months = []
    failure = []

    if @prices.length == 3
      months = [6, 12]
    else
      months = [6]
    end

    months.each do |month|
      calculated_price = MSPricing.calculate(@prices[0], month)
      actual_price = month == 6 ? @prices[1] : @prices[2]

      msg = "Expected price: #{calculated_price} - UI shows: #{actual_price}"
      failure << msg unless actual_price == calculated_price
    end

    puts failure unless failure.empty?
  end

  def self.define_expectations
    months = 6 # default all tests to select 6 mo payment plan

    membership_cost = @prices[1]
    @expect_first_pymt = (membership_cost / months)
    @expect_remain_balance = membership_cost - @expect_first_pymt
  end

  def self.get_expectations
    [@expect_first_pymt, @expect_remain_balance]
  end

  def self.raw_html_price_set
    MSPricing.membership_prices
  end

  def self.enroll
    MSProcess.choose_the_package(raw_html_price_set)
    MSProcess.checkout
    MSFinish.setup_billing
  end

  def self.get_enrolled
    goto_offerings
    check_on_prices
    define_expectations
    enroll
  end

  def self.get_UI_features_list
    # locate UI elements
    summary = @browser.element(:class, 'package-features')
    list_items = summary.elements(:tag_name, 'li').to_a

    # get values
    i = 0
    list_items.each do |item|
      list_items[i] = item.text
      i += 1
    end

    list_items
  end

  def self.get_ui_payments
    # locate UI elements
    boxes = @browser.elements(:css, 'div.column.third').to_a
    elem = boxes[2].elements(:class, 'text--size-small').to_a

    # get values
    actual_first_pymt = elem[0].text.gsub!(/[^0-9|\.]/, '').to_i
    actual_remain_balance = boxes[2].element(:class, 'primary').text.gsub!(/[^0-9|\.]/, '').to_i
    actual_package = elem[1].text.split(' ')[1].downcase

    [actual_first_pymt, actual_remain_balance, actual_package]
  end
end