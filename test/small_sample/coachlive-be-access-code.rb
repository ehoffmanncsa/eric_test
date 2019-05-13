# encoding: utf-8
require_relative '../test_helper'

class CoachLiveBEAccessCode
  attr_accessor :app_name

  def initialize; end

  def start
    @psql = PostgresConnection.new(@app_name)
    @psql.get_connection
  end

  def display_access_code
    puts "-----------------------------------\n" \
         "id\t event_id\t row_id\n" \
         "-----------------------------------\n"
    data = get_data
    data.each do |row|
      puts "%s\t %s\t\t %s" % [row['id'], row['event_id'], row['code']]
    end
  end

  def stop
    @psql.close_connection
  end

  private

  def get_data
    @psql.exec 'select * from access_codes'
  end
end

conn = CoachLiveBEAccessCode.new

if ARGV[0].nil?
  puts "You need to specify an application name. For example: coachlive-be"
  conn.app_name = gets.chomp
else
  conn.app_name = ARGV[0]
end

conn.start
conn.display_access_code
conn.stop
