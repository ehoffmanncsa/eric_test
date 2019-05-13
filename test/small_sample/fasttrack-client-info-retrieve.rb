# encoding: utf-8
require_relative '../test_helper'

class FasttrackClientInfoRetrieve
  attr_accessor :app_name

  def initialize; end

  def start
    @sql = SQLConnection.new(@app_name)
    @sql.get_connection
  end

  def display_client
    puts "---------------------------------------------------------\n" \
         "id\t email\t\t\t\t sport\n" \
         "---------------------------------------------------------\n"
    data = get_data
    data.each do |row|
      puts "%s\t %s\t\t %s" % [row['client_id'], row['email_primary'], row['sport']]
      puts ""
    end
  end

  def stop
    @sql.close_connection
  end

  private

  def get_data
    @sql.exec "select * from client_info_view where email_primary = 'turkeytom@yopmail.com'"
  end
end

conn = FasttrackClientInfoRetrieve.new

if ARGV[0].nil?
  puts "You need to specify an application name. For example: fasttrack"
  conn.app_name = gets.chomp
else
  conn.app_name = ARGV[0]
end

conn.start
conn.display_client
conn.stop
