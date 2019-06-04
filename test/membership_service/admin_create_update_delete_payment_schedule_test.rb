# encoding: utf-8
require_relative '../test_helper'

# MS Regression
# TS-485, TS-486, TS-487
# UI Test: Create/Update/Delete A Payment Schedule Test (Admin Payments Page)

class AdminCUDPaymentScheduleTest < Common
  def setup
    super
    UIActions.fasttrack_login
    MSAdmin.setup(@browser)
  end

  def teardown
    super
  end

  def goto_payments_page
    client_id = MSAdmin.find_active_client_id
    config = Default.env_config
    url = config['fasttrack']['base_url'] + "recruit/admin/payments/#{client_id}"
    puts "[INFO] Attempting to test payment schedule here...\n#{url}"
    @browser.goto url
    sleep 2
  end

  def open_add_schedule
    @browser.a(:class, 'new-payment-js').click
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

  def fill_out_create_schedule_form
    form.text_field(:name, 'scheduleDate').set date
    form.text_field(:name, 'amount').set amount
    form.text_field(:name, 'financeFee').set @given_amount
    @browser.div(:class, 'add-payment-button-js').click
  end

  def find_newest_schedule(table)
    row_position = 0
    index_count = 0
    temp_id = 0

    table.rows.each do |row|
      id = row[0].text.to_i
      if id > temp_id
        temp_id = id
        row_position = index_count
      end

      index_count += 1
    end

    table.rows[row_position]
  end

  def collect_last_schedule_info
    @schedule = find_newest_schedule(payment_table)

    #[id, account, date, amount, finance, total, status, payment_id]
    @schedule_id = @schedule[0].text
    @schedule_date = @schedule[2].text
    @schedule_amount = @schedule[3].text.gsub('$', '').to_f
  end

  def check_schedule_created
    failure = []
    wrong_date_msg = "Last schedule date #{@schedule_date} is not as expected #{@given_date}"
    failure << wrong_date_msg unless @schedule_date == @given_date

    wrong_amount_msg = "Last schedule amount #{@schedule_amount} is not as expected #{@given_amount}"
    failure << wrong_amount_msg unless @schedule_amount == @given_amount

    assert_empty failure
  end

  def preps
    loop do
      MSAdmin.goto_recruiting_dasboard
      MSAdmin.search_client_by_membership
      goto_payments_page
      payment_table.scroll.to :center
      break if table_has_payments
      pp "[INFO] Page has no payment schedules, need to find a different client..."
    end
  end

  def create_payment_schedule
    open_add_schedule
    fill_out_create_schedule_form
  end

  def edit_payment_schedule
    @schedule.button(:title, 'Edit Payment').click
    @schedule.text_field(:name, 'paymentDate').set date
    @schedule.button(:title, 'Update Payment').click
  end

  def check_schedule_edited
    wrong_date_msg = "Updated schedule date #{@schedule_date} is not as expected #{@given_date}"
    assert_equal @given_date, @schedule_date, wrong_date_msg
  end

  def delete_payment_schedule
    @schedule.button(:title, 'Delete Payment').click
    @schedule.button(:class, 'tabledit-confirm-button').click
  end

  def reveal_deleted_schedules
    @browser.element(:text, 'Deleted Payments').click
  end

  def deleted_payments_table
    @browser.div(:id, 'deleted-payments').table(:id, 'payment-schedule')
  end

  def check_schedule_deleted
    reveal_deleted_schedules

    deleted_schedule = find_newest_schedule(deleted_payments_table)
    expected_id = deleted_schedule[0].text
    assert_equal expected_id, @schedule_id, 'Deleted schedule did not show up in Deleted Payments table.'
  end

  def test_admin_create_update_delete_payment_schedule
    preps

    create_payment_schedule
    collect_last_schedule_info
    check_schedule_created

    edit_payment_schedule
    collect_last_schedule_info
    check_schedule_edited

    delete_payment_schedule
    check_schedule_deleted
  end
end