# encoding: utf-8

# This module helps with common behaviors
# Performed by an NCSA Admin around fasttrack
module Fasttrack
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

  def self.delete_scouting_report_data
    @sql = SQLConnection.new('fasttrack')
    begin
      @sql.get_connection
      @sql.exec "delete from scouting_reports where client_id = 5795323"
      @sql.exec "delete from scouting_report_key_skills where scouting_report_id not in (select id from scouting_reports)"
      @sql.exec "delete from scouting_report_marketing_plans where scouting_report_id not in (select id from scouting_reports)"
      @sql.exec "delete from scouting_report_communication_quarters where scouting_report_id not in (select id from scouting_reports)"
      @sql.exec "delete from scouting_report_communications where scouting_report_communication_quarter_id not in (select id from scouting_report_communication_quarters)"
      @sql.exec "delete from scouting_report_intro_email_notes where scouting_report_id not in (select id from scouting_reports)"
      @sql.exec "delete from scouting_report_video_clips where scouting_report_id not in (select id from scouting_reports)"
      @sql.exec "delete from scouting_report_target_schools where scouting_report_id not in (select id from scouting_reports)"
    rescue StandardError => e
      raise 'Could not connect to fasttrack or delete existing scouting report records'
    end
  end

  def self.retrieve_current_scouting_report_id
    begin
      query = "select id from dbo.scouting_reports
             where client_id = 5795323"

    rescue StandardError => e
      raise 'Could not connect to fasttrack or fetch scouting report id'
    end
  ids = retrieve_scouting_report_id(query)
  ids.first["id"]
  end

  def self.retrieve_target_school_ids_for(scouting_report_id)
    begin
      query = "select id from dbo.scouting_report_target_schools
             where scouting_report_id = #{scouting_report_id.to_i}"
    rescue StandardError => e
      raise 'Could not connect to fasttrack or fetch scouting report target school ids'
    end
    ids = retrieve_scouting_report_id(query)
    ids.map{|row| row["id"]}
  end

  def self.retrieve_marketing_plans_ids_for(scouting_report_id)
    begin
      query = "select id from dbo.scouting_report_marketing_plans
             where scouting_report_id = #{scouting_report_id.to_i}"
    rescue StandardError => e
      raise 'Could not connect to fasttrack or fetch scouting report marketing plan ids'
    end
    ids = retrieve_scouting_report_id(query)
    ids.map{|row| row["id"]}
  end

  def self.retrieve_scouting_report_id(query)
    data = @sql.exec query
    id = []
    data.each do |row|
    id << row['id']
    end
  end
end
