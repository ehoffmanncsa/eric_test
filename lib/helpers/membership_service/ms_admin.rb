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
  end

  def self.retrieve_active_client_id_from_DB
    query = "SELECT TOP 100 client_id FROM dbo.client WHERE status = 'Client Created' ORDER BY status_date desc"
    data = @sql.exec query
    client_ids = []
    data.each do |row|
      client_ids << row['client_id']
    end

    client_ids.sample
  end

  def self.payment_table
    @browser.table(id: 'payment-schedule')
  end

  def self.table_has_payments
    rows = payment_table.rows.to_a
    rows.length > 1 ? true : false
  end

  def self.goto_payments_page
    loop do
      client_id = retrieve_active_client_id_from_DB
      url = @config['fasttrack']['base_url'] + "recruit/admin/payments/#{client_id}"
      puts "[INFO] Attempting to test with client id #{client_id} ...\n#{url}"
      @browser.goto url
      sleep 2

      payment_table.scroll.to :center
      break if table_has_payments
      puts "[INFO] Page has no payment schedules, need to find a different client..."
    end
  end
end
