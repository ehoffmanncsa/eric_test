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

  def self.choose_the_package(price_set, eighteen_mo = false)
    # get initial cart count
    cart_count = get_cart_count.nil? ? 0 : get_cart_count

    # select package as assigned, increment cart count by 1
    # select 6 months payment plan by default for most cases
    # to avoid violating braintree test credit charge cap at $2000
    # select 18mo plan for 18mo test cases
    (eighteen_mo || price_set.length == 1) ? price_set.last.click : price_set[1].click
    sleep 5

    cart_count += 1
    sleep 2

    # compare cart count before and after selecting package
    new_cart_count = get_cart_count
    msg = "[ALERT] Cart count is #{new_cart_count} after selecting a package"
    puts msg unless cart_count.eql? new_cart_count
  end

  def self.checkout
    @browser.element(:class, 'button--next').click; sleep 3
    Watir::Wait.until(timeout: 90) { @browser.url.include? 'clientrms/membership/enrollment' }
  end


  def self.apply_discount(code)
    @browser.element(:placeholder, 'Enter Discount Code').send_keys code
    @browser.element(:class, 'apply').click; sleep 2
    Watir::Wait.until { discount_message.present? }

    # need to fix discount message checker
    #check_discount_message(code)
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

  def self.select_alacarte_item
    loop do
      random_item = alacarte_blocks.sample

      error = nil
      begin
        random_item.element(:class, 'button--medium').click
      rescue => error; end

      if error.nil?
        sleep 4
        return random_item.element(:tag_name, 'h3').text # name of the item
      end
    end
  end

  def self.pick_VIP_items(items_count = nil)
    open_alacarte_table
    items_picked = []
    items_count = items_count.nil? ? rand(1 .. alacarte_blocks.length) : items_count

    # get initial cart count
    cart_count = get_cart_count.nil? ? 0 : get_cart_count

    i = 0
    while i < items_count
      item_text = select_alacarte_item

      # make sure cart count increments
      cart_count += 1
      msg = "[ALERT] Cart count is incorrect, expecting #{cart_count} - show #{get_cart_count}"
      puts msg unless cart_count.eql? get_cart_count

      i += 1

      if item_text == 'VIP Videos'
        if !(items_picked.include? item_text)
          items_picked << item_text
        end
      else
        if items_picked.include? item_text
          items_picked.map! { |word| word == item_text ? word + 's' : word }
        else
          items_picked << item_text
        end
      end
    end

    items_picked
  end
end
