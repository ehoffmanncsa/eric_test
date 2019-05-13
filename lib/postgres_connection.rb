# encoding: utf-8
require 'pg'

class PostgresConnection
  def initialize(app_name)
    @app_name = app_name
  end

  def get_connection
    @conn = PG::Connection.new(host: creds['host'],
      user: creds['username'], dbname: creds['dbname'],
      port: 5432, password: creds['password'])
  end

  def exec(query)
    @conn.exec query
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
    file_path = File.expand_path("../../config/postgres_databases.yml", __FILE__)
    YAML.load(File.open(file_path))[environment][@app_name]
  end
end
