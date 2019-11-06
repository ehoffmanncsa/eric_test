# encoding: utf-8

# Set up a new lead for POS base 2 conditions: grad year and package type
# choosing and returning 6 payments financing option as default
# that way we can test for remaining balance and first payment made
module MSPricing
  def self.setup(ui_object, package = nil, eighteen_mo = nil)
    @browser = ui_object
    @package = package
    @eighteen_mo = eighteen_mo
  end

  def self.gather_all_payment_plan_cells
    @browser.elements(class: ['select-plan', 'js-package-button']).to_a
  end

  def self.predict_payment_plans_position
    cells = gather_all_payment_plan_cells

    case cells.length
      when 12 then return pricing_set1(cells)
      when 9 then return pricing_set2(cells)
      when 6 then return pricing_set3(cells)
      when 3 then return pricing_set4(cells)
    end
  end

  def self.pricing_set1(cells)
    #            1 mo       6 mo      12 mo     18 mo
    champion = [cells[9], cells[6], cells[3], cells[0]]
    elite = [cells[10], cells[7], cells[4], cells[1]]
    mvp = [cells[11], cells[8], cells[5], cells[2]]

    [champion, elite, mvp]
  end

  def self.pricing_set2(cells)
    #            1 mo       6 mo      12 mo
    champion = [cells[6], cells[3], cells[0]]
    elite = [cells[7], cells[4], cells[1]]
    mvp = [cells[8], cells[5], cells[2]]

    [champion, elite, mvp]
  end

  def self.pricing_set3(cells)
    #             1 mo      6 mo
    champion = [cells[3], cells[0]]
    elite = [cells[4], cells[1]]
    mvp = [cells[5], cells[2]]

    [champion, elite, mvp]
  end

  def self.pricing_set4(cells)
    #             1 mo
    champion = [cells[0]]
    elite = [cells[1]]
    mvp = [cells[2]]

    [champion, elite, mvp]
  end

  def self.membership_prices(package = nil)
    cells = []

    package ||= @package

    case package
      when 'champion' then cells = predict_payment_plans_position[0]
      when 'elite' then cells = predict_payment_plans_position[1]
      when 'mvp' then cells = predict_payment_plans_position[2]
    end

    cells
  end

  def self.collect_prices(package = nil)
    raw_html_set = membership_prices(package)
    prices = []

    # extract 1mo price
    prices << raw_html_set[0].element(class: 'full').text.gsub(/\D/, '').to_i

    # extract payment plan prices
    #range_end = @eighteen_mo ? raw_html_set.length - 1 : raw_html_set.length - 2
    range_end = if @eighteen_mo && package != 'champion'
                  raw_html_set.length - 1
                else
                  raw_html_set.length - 2
                end

    for i in (1 .. range_end) do
      prices << raw_html_set[i].element(class: 'small').text.gsub(/\D/, '').to_i
    end

    prices # respectively [1mo, 6mo, 12mo, 18mo] or [1mo, 6mo, 12mo] or [1mo]
  end

  def self.collect_one_month_plans
    [
      predict_payment_plans_position[0][0],
      predict_payment_plans_position[1][0],
      predict_payment_plans_position[2][0]
    ]
  end

  def self.one_month_plan_prices
    price_set = collect_one_month_plans
    prices = []

    price_set.each do |price|
      prices << price.element(class: 'full').text.gsub(/\D/, '').to_i
    end

    prices
  end

  def self.calculate(one_month_plan, months, discount_code = nil)
    interest_rate = 1
    case months
      when 6 then interest_rate = 1.11
      when 12 then interest_rate = 1.2
      when 18 then interest_rate = 1.338
    end

    pay_rate = (discount_code.nil?) ? 1 : (1 - Default.static_info['ncsa_discount_code'][discount_code].to_f)

    # this will produce a payment plan cost with financing fees (interest and/or discount)
    ((((one_month_plan * pay_rate).round) * interest_rate) / months).round * months
  end
end
