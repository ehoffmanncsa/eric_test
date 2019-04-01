# encoding: utf-8

# Set up a new lead for POS base 2 conditions: grad year and package type
# choosing and returning 6 payments financing option as default
# that way we can test for remaining balance and first payment made
module MSProcess
  def self.setup(ui_object)
    @browser = ui_object
  end

  def self.get_cart_count
    cart = @browser.element(:id, 'shopping-cart')
    count = cart.element(:class, 'js-cart-count').text
    return count.gsub!(/[^0-9]/, '').to_i unless count.nil?
  end

  def self.choose_the_package(price_set)
    # get initial cart count
    cart_count = get_cart_count.nil? ? 0 : get_cart_count

    # select package as assigned, increment cart count by 1
    # select 6 months payment plan by default for now
    # to avoid violating braintree test credit charge cap at $2000
    price_set[1].click
    cart_count += 1
    sleep 2

    # compare cart count before and after selecting package
    new_cart_count = get_cart_count
    msg = "[ERROR] Cart count #{new_cart_count} after selecting a package"
    raise msg unless cart_count.eql? new_cart_count
  end

  def self.checkout
    @browser.element(:class, 'button--next').click; sleep 1
    Watir::Wait.until(timeout: 90) { @browser.url.include? 'clientrms/membership/enrollment' }
    sleep 2
  end


  def self.apply_discount_offerings(code)
    @browser.element(:placeholder, 'Enter Discount Code').send_keys code
    @browser.element(:class, 'apply').click; sleep 2
    Watir::Wait.until { discount_message.present? }

    check_discount_message(code)
  end

  def self.discount_message
    @browser.element(:class, 'discount-message')
  end

  def self.check_discount_message(code)
    expect_msg = "Discount code #{code.upcase} successfully applied"
    actual_msg = discount_message.text.split('!').first
    raise "[Incorrect Message] Expect: #{expect_msg} - Actual: #{actual_msg}" unless actual_msg.eql? expect_msg
  end

  def self.remove_discount
    @browser.link(:text, 'Remove').click
    Watir::Wait.while { discount_message.present? }
  end

  def self.pick_VIP_items(all = false)
    # get initial cart count
    cart_count = get_cart_count.nil? ? 0 : get_cart_count

    # activate alacarte table
    @browser.element(:class, 'alacarte-features').element(:class, 'vip-toggle-js').click

    # add one of each alacarte options into cart
    # and make sure cart count increments
    item_names = []
    msg = "[ERROR] Cart count #{get_cart_count} after selecting #{cart_count} VIP items"

    if all
      all_VIP_items.each do |item|
        item.element(:class, 'button--medium').click; sleep 2
        cart_count += 1
        raise msg unless cart_count.eql? get_cart_count
      end
    else
      block = all_VIP_items.sample
      block.element(:class, 'button--medium').click; sleep 2
      cart_count += 1
      raise msg unless cart_count.eql? get_cart_count
    end

    item_names
  end

  def self.all_VIP_items
    @browser.elements(:class, 'alacarte-block').to_a
  end
end
