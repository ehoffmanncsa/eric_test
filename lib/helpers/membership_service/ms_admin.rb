# encoding: utf-8

# This module helps with common behaviors
# Performed by an NCSA Admin around a client's Payments
module MSAdmin
  def self.setup(ui_object)
    @browser = ui_object
  end

  def self.goto_recruiting_dasboard
    fasttrack = Default.env_config['fasttrack']
    recruiting_dasboard = fasttrack['base_url'] + fasttrack['recruiting_dasboard']
    @browser.goto recruiting_dasboard
  end

  def self.search_client_by_membership
    premium = %w[champion elite mvp].sample
    @browser.text_field(:name, 'q').set premium
    @browser.text_field(:name, 'q').send_keys :enter
    sleep 2
  end

  def self.search_results_table
    @browser.table(:class, %w[m-tbl d-wide l-bln-mg-btm-2])
  end

  def self.random_row
    rows = search_results_table.elements(:tag_name, 'tr').to_a
    rows.sample
  end

  def self.find_active_client_id
    row = nil
    loop do
      row = random_row
      year = row.elements(:tag_name, 'td')[3].text
      break if year.to_i >= Time.now.year
    end

    extract_clientid(row)
  end

  def self.extract_clientid(client_row)
    client_name_element = client_row.elements(:tag_name, 'td')[1]
    url = client_name_element.element(:tag_name, 'a').attribute_value('href')
    url.gsub(/[^0-9]/, '')
  end
end
