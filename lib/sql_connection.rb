# encoding: utf-8
require 'tiny_tds'

class SQLConnection
  def initialize(app_name)
    @app_name = app_name
  end

  def get_connection
    @conn = TinyTds::Client.new(host: creds['host'],
      username: creds['username'], database: creds['dbname'],
      port: 1433, password: creds['password'])
  end

  def exec(query)
    @conn.execute query
  end

  def close_connection
    @conn.close
  end

  private

  def environment
    ENV['CONFIG_FILE'] ||= '/staging.yml'
    words = ENV['CONFIG_FILE'].split(/\W+/)
    words.pop
    words.last
  end

  def creds
    file_path = File.expand_path("../../config/sql_databases.yml", __FILE__)
    YAML.load(File.open(file_path))[environment][@app_name]
  end
end
