# encoding: utf-8

# Set up a new lead for POS base 2 conditions: grad year and package type
# choosing and returning 6 payments financing option as default
# that way we can test for remaining balance and first payment made
module MSTestTemplate
  def self.setup(ui_object, recruit_email = nil, package = nil, eighteen_mo = false)
    @browser = ui_object
    @recruit_email = recruit_email
    @eighteen_mo = eighteen_mo

    MSSetup.setup(ui_object)
    MSPricing.setup(ui_object, package, eighteen_mo)
    MSProcess.setup(ui_object)
    MSFinish.setup(ui_object)
  end

  def self.goto_offerings
    sleep 2
    MSSetup.set_password
    MSSetup.goto_offerings
  end

  def self.open_payment_plan
    MSSetup.open_payment_plan

    if @eighteen_mo
      MSSetup.reveal_18_mo_plan
    end
  end

  def self.check_on_prices
    @prices = MSPricing.collect_prices # respectively [1mo, 6mo, 12mo, 18mo]
    months = []
    failure = []

    case @prices.length
      when 2 then months = [6]
      when 3 then months = [6, 12]
      when 4 then months = [6, 12, 18]
    end

    months.each do |month|
      calculated_price = MSPricing.calculate(@prices[0], month)

      case month
        when 6 then actual_price = @prices[1]
        when 12 then actual_price = @prices[2]
        when 18 then actual_price = @prices[3]
      end

      msg = "Expected #{month} months price: #{calculated_price} - UI shows: #{actual_price}"
      failure << msg unless actual_price == calculated_price
    end

    puts failure unless failure.empty?
  end

  def self.define_expectations
    months = 0
    membership_cost = 0

    # default all tests to select 6 mo payment plan
    # unless there is eigteen months enabled
    if @eighteen_mo
      months = 18
      membership_cost = @prices.last
    else
      months = 6
      membership_cost = @prices[1]
    end


    @expect_first_pymt = (membership_cost / months)
    @expect_remain_balance = membership_cost - @expect_first_pymt
  end

  def self.get_expectations
    [@expect_first_pymt, @expect_remain_balance]
  end

  def self.raw_html_price_set
    MSPricing.membership_prices
  end

  def self.enroll(ach: false, checkout_cart: false)
    MSProcess.choose_the_package(raw_html_price_set, @eighteen_mo)
    (checkout_cart.eql? true) ? MSProcess.checkout_cart : MSProcess.checkout
    MSFinish.setup_billing(ach)
  end

  def self.get_enrolled(ach: false, checkout_cart: false)
    goto_offerings
    open_payment_plan
    check_on_prices
    define_expectations
    enroll(ach: ach, checkout_cart: checkout_cart)
  end

  def self.get_UI_features_list
    Watir::Wait.until(timeout: 60) { @browser.url.include? 'clientrms/accounts' }

    # locate UI elements
    summary = @browser.element(class: 'package-features')
    list_items = summary.elements(tag_name: 'li').to_a

    # get values
    i = 0
    list_items.each do |item|
      list_items[i] = item.text
      i += 1
    end

    list_items
  end

  def self.get_ui_payments
    Watir::Wait.until(timeout: 60) { @browser.url.include? 'clientrms/finances' }

    # locate UI elements
    boxes = @browser.elements(css: 'div.column.third').to_a
    elem = boxes[2].elements(class: 'text--size-small').to_a

    # get values
    actual_first_pymt = elem[0].text.gsub!(/[^0-9|\.]/, '').to_i
    actual_remain_balance = boxes[2].element(class: 'primary').text.gsub!(/[^0-9|\.]/, '').to_i
    actual_package = elem[1].text.split(' ')[1].downcase

    [actual_first_pymt, actual_remain_balance, actual_package]
  end
end
