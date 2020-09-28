# encoding: utf-8

# This module helps with common behaviors
# Performed by an NCSA Admin around a client's Payments
module MSAdmin
  def self.setup(ui_object)
    @browser = ui_object
    @config = Default.env_config

    app_name = 'fasttrack'
    @sql = SQLConnection.new(app_name)
    @sql.get_connection

    app_name = 'features_service'
    @psql = PostgresConnection.new(app_name)
    @psql.get_connection
  end

  def self.retrieve_random_active_client_id
    query = "SELECT TOP 100 client_id
             FROM dbo.client
             WHERE status = 'Client Created'
             ORDER BY status_date DESC"
    retrive_client_id(query)
  end

  def self.retrieve_client_id_by_program(program)
    query = "SELECT TOP 100 client_id
             FROM dbo.client_info_view
             WHERE status = 'Client Created'
             AND payment_option_name = '#{program}'
             ORDER BY status_date DESC"
    retrive_client_id(query)
  end

  def self.retrive_client_id(query)
    data = @sql.exec query
    client_ids = []
    data.each do |row|
      client_ids << row['client_id']
    end

    client_ids.sample
  end

  def self.update_point_of_sale_event(posclient_id)
    query =  "UPDATE point_of_sale_events
              SET updated_at = current_timestamp - INTERVAL '3' HOUR  ,
              created_at = current_timestamp - INTERVAL '3' HOUR
              WHERE CLIENT_ID = '#{posclient_id}'
              and type = 'PointOfSale::NewClientActivated'"
    @psql.exec query
  end

  def self.payment_table
    @browser.table(id: 'payment-schedule')
  end

  def self.table_has_payments
    rows = payment_table.rows.to_a
    rows.length > 1 ? true : false
  end

  def self.goto_payments_page(client_id = nil)
    loop do
      client_id ||= retrieve_random_active_client_id
      url = @config['fasttrack']['base_url'] + "recruit/admin/payments/#{client_id}"
      puts "[INFO] Attempting to test with client id #{client_id} ...\n#{url}"
      @browser.goto url
      sleep 4

      payment_table.scroll.to :center
      break if table_has_payments
      puts "[INFO] Page has no payment schedules, going to try a different client..."
      client_id = nil
    end
  end

  def self.goto_recruiting_dashboard
    url = @config['fasttrack']['base_url'] + @config['fasttrack']['recruiting_dasboard']
    @browser.goto url
  end

  def self.upgrade_downgrade_payment_plan
    payment_plan_arr = ['1 Month (0%)','6 Month (11%)','12 Month (20%)','18 Month (33.8%)']

    payment_plan_arr.sample
  end

  def self.upgrade_or_down_grade_to(membership_name)
    @browser.i(class: 'fa-pencil').click
    modal.select_list(name: 'packageName').select membership_name
    modal.select_list(name: 'numPayments').select rand(1 .. 18).to_s
    modal.select_list(name: 'paymentPlan').select upgrade_downgrade_payment_plan
    modal.button(value: 'Preview Membership Change').click
    sleep 3
    Watir::Wait.until(timeout: 30) { modal.div(class: %w[js_change_payment change_form]).present? }
    modal.button(value: 'Change Membership').click
    Watir::Wait.until(timeout: 30) { !(modal.present?) }
    sleep 2
  end

  def self.modal
    @browser.div(class: 'modal')
  end
end
