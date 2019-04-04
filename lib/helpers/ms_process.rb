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
    msg = "[ALERT] Cart count is #{new_cart_count} after selecting a package"
    puts msg unless cart_count.eql? new_cart_count
  end

  def self.checkout
    @browser.element(:class, 'button--next').click; sleep 1
    Watir::Wait.until(timeout: 90) { @browser.url.include? 'clientrms/membership/enrollment' }
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

  def self.open_alacarte_table
    @browser.element(:class, 'alacarte-features').element(:class, 'vip-toggle-js').click
  end

  def self.alacarte_blocks
    @browser.elements(:class, 'alacarte-block').to_a
  end

  def self.pick_VIP_items(items_count = nil)
    open_alacarte_table
    items_picked = []
    items_count = items_count.nil? ? rand(1 .. alacarte_blocks.length) : items_count

    # get initial cart count
    cart_count = get_cart_count.nil? ? 0 : get_cart_count

    i = 0
    item_text = nil
    while i < items_count
      loop do
        block = alacarte_blocks.sample
        add_button = block.element(:class, 'button--medium')

        error = nil;
        begin
          block.element(:class, 'button--medium').click
        rescue => error; end

        if error.nil?
          item_text = block.element(:tag_name, 'h3').text
          sleep 4
          break
        end
      end

      # make sure cart count increments
      cart_count += 1
      msg = "[ALERT] Cart count is incorrect, expecting #{cart_count} - show #{get_cart_count}"
      puts msg unless cart_count.eql? get_cart_count

      i += 1

      items_picked << item_text unless items_picked.include? item_text
    end

    items_picked
  end
end
