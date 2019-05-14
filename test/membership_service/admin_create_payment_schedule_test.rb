# encoding: utf-8
require_relative '../test_helper'

# TS-485: MS Regression
# UI Test: Create New Payment Schedule Test (Admin Payments Page)

class AdminCreatePaymentScheduleTest < Common
  def setup
    super

    @config = Default.env_config
    UIActions.fasttrack_login
  end

  def teardown
    super
  end

  def goto_recruiting_dasboard
    fasttrack = Default.env_config['fasttrack']
    recruiting_dasboard = fasttrack['base_url'] + fasttrack['recruiting_dasboard']
    @browser.goto recruiting_dasboard
  end

  def search_client
    premium = %w[champion elite mvp].sample
    @browser.text_field(:name, 'q').set premium
    @browser.text_field(:name, 'q').send_keys :enter
    sleep 2
  end

  def client_table
    @browser.table(:class, %w[m-tbl d-wide l-bln-mg-btm-2])
  end

  def random_row
    rows = client_table.elements(:tag_name, 'tr').to_a
    rows.sample
  end

  def find_possible_active_client
    row = nil
    loop do
      row = random_row
      year = row.elements(:tag_name, 'td')[3].text
      if year.to_i >= Time.now.year
        return row
      end
    end
  end

  def extract_clientid(client_row)
    client_name_element = client_row.elements(:tag_name, 'td')[1]
    url = client_name_element.element(:tag_name, 'a').attribute_value('href')
    url.gsub(/[^0-9]/, '')
  end

  def goto_payments_page
    client_id = extract_clientid(find_possible_active_client)
    url = @config['fasttrack']['base_url'] + "recruit/admin/payments/#{client_id}"
    puts "[INFO] Attempting to add schedule here...\n#{url}"
    @browser.goto url
    sleep 2
  end

  def open_add_schedule
    @browser.a(:class, 'new-payment-js').click
    sleep 2
  end

  def payment_table
    @browser.table(:id, 'payment-schedule')
  end

  def table_has_payments
    rows = payment_table.rows.to_a
    rows.length > 1 ? true : false
  end

  def form
    @browser.form(:class, 'create_payment')
  end

  def date
    @given_date = Time.now.strftime("%m/%d/%Y")
  end

  def amount
    @given_amount = rand(100.00 .. 300.00).round(2) # random float between 100 and 300 with 2 decimals
  end

  def create_schedule
    form.text_field(:name, 'scheduleDate').set date
    form.text_field(:name, 'amount').set amount
    form.text_field(:name, 'financeFee').set @given_amount
    sleep 1

    @browser.div(:class, 'add-payment-button-js').click
    sleep 1
  end

  def find_newest_schedule
    row_position = 0
    index_count = 0
    temp_id = 0

    payment_table.rows.each do |row|
      id = row[0].text.to_i
      if id > temp_id
        temp_id = id
        row_position = index_count
      end

      index_count += 1
    end

    payment_table.rows[row_position]
  end

  def collect_last_schedule_info
    schedule = find_newest_schedule

    #[id, account, date, amount, finance, total, status, payment_id]
    @schedule_date = schedule[2].text
    @schedule_amount = schedule[3].text.gsub('$', '').to_f
  end

  def check_schedule_created
    collect_last_schedule_info

    failure = []
    wrong_date_msg = "Last schedule date #{@schedule_date} is not as expected #{@given_date}"
    failure << wrong_date_msg unless @schedule_date == @given_date

    wrong_amount_msg = "Last schedule amount #{@schedule_amount} is not as expected #{@given_amount}"
    failure << wrong_amount_msg unless @schedule_amount == @given_amount

    assert_empty failure
  end

  def test_admin_create_new_payment_schedule
    # preps
    loop do
      goto_recruiting_dasboard
      search_client
      goto_payments_page
      break if table_has_payments
      pp "[INFO] Page has no payment schedules, need to find a different client..."
    end

    open_add_schedule
    create_schedule
    check_schedule_created
  end
end
