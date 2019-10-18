# encoding: utf-8

# This module helps with common behaviors
# Helps find a usable event
module EventHelper
  def self.setup(ui_object)
    @browser = ui_object
    @config = Default.env_config

    app_name = 'fasttrack'
    @sql = SQLConnection.new(app_name)
    @sql.get_connection
  end

  def self.retreive_random_event_id
    query = "
      SELECT e.event_id
      FROM event e tablesample(100)
      JOIN event_source es ON e.event_source_id = es.event_source_id
      JOIN partner_pgm pgm ON es.partner_pgm_id = pgm.partner_pgm_id
      WHERE e.deleted = 0"

    data = @sql.exec query
    event_ids = []
    data.each do |row|
      event_ids << row['event_id']
    end

    event_ids.sample
  end
end
