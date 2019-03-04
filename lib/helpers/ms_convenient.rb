# encoding: utf-8

# Set up a new lead for POS base 2 conditions: grad year and package type
# choosing and returning 6 payments financing option as default
# that way we can test for remaining balance and first payment made
module MSConvenient
  def self.setup(ui_object)
    @browser = ui_object

    MSSetup.setup(ui_object)
    MSProcess.setup(ui_object)
    MSFinish.setup(ui_object)
  end

  # to purchase only membership package
  def self.buy_package(email, package)
    MSPricing.setup(@browser, package)

    MSSetup.set_password(email)
    MSSetup.goto_offerings
    MSSetup.open_payment_plan

    MSProcess.choose_the_package(MSPricing.membership_prices)
    MSProcess.checkout

    MSFinish.setup_billing
  end

  # to purchase only alacarte items
  def self.buy_alacarte(email, all = true)
    MSSetup.set_password(email)
    MSSetup.goto_offerings

    MSProcess.pick_VIP_items(all)
    MSProcess.checkout
    MSFinish.setup_billing
  end

  # to purchase both a membership package and some alacarte items
  def self.buy_combo(email, package)
    MSSetup.set_password(email)
    MSSetup.goto_offerings
    MSSetup.open_payment_plan

    MSPricing.setup(@browser, package)
    MSProcess.choose_the_package(MSPricing.membership_prices)
    MSProcess.pick_VIP_items
    MSProcess.checkout
    MSFinish.setup_billing
  end

  # to make payment using ACH instead of credit card
  def self.buy_with_ACH_payment(email, package)
    MSSetup.set_password(email)
    MSSetup.goto_offerings
    MSSetup.open_payment_plan

    MSPricing.setup(@browser, package)
    MSProcess.choose_the_package(MSPricing.membership_prices)
    MSProcess.checkout
    MSFinish.setup_billing(true)
  end
end
