# encoding: utf-8
# Common Coach Live api stuff
module AthleticEventApi
  class << self
    attr_accessor :athletic_event
  end

  def self.setup
    @connection_client = AthleticEventServiceClient.new
    @athletic_event_data = athletic_event_data
    @expected_data = @athletic_event_data[:athletic_event]
    @event_name = @athletic_event_data[:athletic_event][:name]
    @event_date = @athletic_event_data[:athletic_event][:start_date]
    @event_city = @athletic_event_data[:athletic_event][:city]
    @event_state = @athletic_event_data[:athletic_event][:state]
    @event_logo = @athletic_event_data[:athletic_event][:logo_url]
    @event_venue_name = @athletic_event_data[:athletic_event][:venues][0][:name]
  end

  def self.date(days_from_now = 2)
    target_day = Date.today + days_from_now
    date = DateTime.new(target_day.year, target_day.month, target_day.day, 12).to_s
    date.split('+')[0] + 'Z'
  end

  def self.position
    position_arr = ['Center', 'Point Guard', 'Power Forward', 'Shooting Guard', 'Small Forward']

    position_arr.sample
  end

  def self.team_name
    team_name_arr = ['13U','14U','15U','16U','17U','18U']

    team_name_arr.sample
  end

  def self.logo_urls
    logo_arr = ['https://cdn1.sportngin.com/attachments/text_block/8390/8599/NAT_FINALS_1_medium.jpg',
    'https://cdn3.sportngin.com/attachments/photo/9426/5867/NOR_CAL_SPRING_SHOWCASE_large.png',
    'https://cdn3.sportngin.com/attachments/text_block/5885/7402/NERR_Super_16_medium.png']

    logo_arr.sample
  end
end
