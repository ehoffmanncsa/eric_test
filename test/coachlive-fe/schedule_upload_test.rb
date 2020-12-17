# frozen_string_literal: true

require_relative '../test_helper'

require 'time'
require 'date'

# UI Test: upload csv that will create new client rms profiles
class ScheduleCSVTest < Common
  def setup
    super

    @connection_client = AthleticEventServiceClient.new
    @athletic_event_data = athletic_event_data
    @expected_data = @athletic_event_data[:athletic_event]
    @event_name = @athletic_event_data[:athletic_event][:name]
    @coach_packet_config = Default.env_config['coach_packet']

    CoachPacket_AdminUI.setup(@browser)
    UIActions.fasttrack_login(username = @coach_packet_config['admin_username'],
                              password = @coach_packet_config['admin_password'])

    AthleticEventUI.setup(@browser)
  end

  def athletic_event_data
    {
      athletic_event: {
        access_type: 'non-purchasable',
        age_range: MakeRandom.age_range,
        description: MakeRandom.lorem(rand(1..4)),
        end_date: AthleticEventApi.date(rand(2..4)),
        start_date: AthleticEventApi.date,
        name: MakeRandom.company_name,
        point_of_contact_email: MakeRandom.fake_email,
        point_of_contact_name: MakeRandom.first_name.to_s + MakeRandom.last_name.to_s,
        registration_link: MakeRandom.url,
        website: MakeRandom.url,
        city: MakeRandom.city,
        state: MakeRandom.state,
        logo_url: AthleticEventApi.logo_urls,
        coach_live_approved: true,
        status: 'Activated',
        activated_at: AthleticEventApi.date,
        event_operator_id: 9
      },
      sports: [
        { ncsa_id: 17_638 }
      ]
    }
  end

  def create_athletic_event
    @new_athletic_event = begin
                            retries ||= 0
                            @connection_client.post(
                              url: '/api/athletic_events/v1/athletic_events',
                              json_body: @athletic_event_data.to_json
                            )
                          rescue StandardError => e
                            msg = "#{e} \nPOST body \n#{@athletic_event_data} \nGoing to retry"
                            puts msg; sleep 2
                            retry if (retries += 1) < 2
                          end

    add_venues(@new_athletic_event['data']['id'])
  end

  def add_venues(athletic_event_id)
    venues = [
      {
        athletic_event_id: athletic_event_id,
        address1: MakeRandom.address,
        address2: MakeRandom.address2,
        city: MakeRandom.city,
        country: 'USA',
        name: 'testvenue1',
        state: MakeRandom.state,
        zip: MakeRandom.zip_code
      },
      {
        athletic_event_id: athletic_event_id,
        address1: MakeRandom.address,
        address2: MakeRandom.address2,
        city: MakeRandom.city,
        country: 'USA',
        name: 'testvenue2',
        state: MakeRandom.state,
        zip: MakeRandom.zip_code
      }
    ]

    venues.each do |venue|
      retries ||= 0
      @connection_client.post(
        url: '/api/athletic_events/v1/venues',
        json_body: venue.to_json
      )
    rescue StandardError => e
      msg = "#{e} \nPOST body \n#{venue} \nGoing to retry"
      puts msg; sleep 2
      retry if (retries += 1) < 2
    end
  end

  def my_event_created
    url = "/api/athletic_events/v1/athletic_events/#{@new_athletic_event['data']['id']}"
    @connection_client.get(url: url)
    @event_id = @new_athletic_event['data']['id']
  end

  def select_event
    @browser.goto "https://qa.ncsasports.org/recruit/admin/coach_packet_athletic_events/#{@event_id}"
    sleep 3
  end

  def search_for_event
    search = @browser.element("data-automation-id": 'SearchBox')
    search.scroll.to
    @browser.text_field(type: 'text').set @event_name
    sleep 2
  end

  def open_event
    open_event = @browser.element(text: @event_name)
    open_event.click
    sleep 2
  end

  def select_schedule
    @browser.goto "https://coachlive-staging.ncsasports.org/events/event/#{@event_id}/schedule"
    sleep 3
  end

  def my_roster_info
    times = []; venues = []; locations = []
    team1_names = []; team2_names = []
    file = CSV.read('schedule.csv'); file.shift
    file.each do |row|
      locations << (row[7]).to_s
      times << (row[8]).to_s
      venues << (row[6]).to_s
      team1_names << "#{row[1]} #{row[0]}"
      team2_names << "#{row[3]} #{row[2]}"
    end

    @times = times
    @venues =  venues
    @locations = locations
    @team1_names = team1_names
    @team2_names = team2_names
  end

  def check_team1_name
    failure = []
    current_team1_name = ""
    begin
      five_minutes = 300 # seconds
      @team1_names.each do |team1_name|
        current_team1_name = team1_name
        Timeout.timeout(five_minutes) do
          html = @browser.html
          break if html.include? team1_name

          @browser.refresh
          sleep 2
        end
      end
    rescue StandardError => e
      failure << "Team 1 name  #{current_team1_name} not found" unless @browser.html.include? current_team1_name
    end
    assert_empty failure
  end

  def check_team2_name
    failure = []
    current_team2_name = ""
    begin
      five_minutes = 300 # seconds
      @team2_names.each do |team2_name|
        current_team2_name = team2_name
        Timeout.timeout(five_minutes) do
          html = @browser.html
          break if html.include? team2_name

          @browser.refresh
          sleep 2
        end
      end
    rescue StandardError => e
      failure << "Team 2 name  #{current_team2_name} not found" unless @browser.html.include? current_team2_name
    end
    assert_empty failure
  end

  def check_location
    failure = []
    current_location = ""
    begin
      five_minutes = 300 # seconds
      @locations.each do |location|
        current_location = location
        Timeout.timeout(five_minutes) do
          html = @browser.html
          break if html.include? location

          @browser.refresh
          sleep 2
        end
      end
    rescue StandardError => e
      failure << "Location name  #{current_location} not found" unless @browser.html.include? current_location
    end
    assert_empty failure
  end

  def select_teams
    @browser.goto "https://coachlive-staging.ncsasports.org/events/event/#{@event_id}/teams"
    sleep 3
  end

  def coach_packet_admin_upload_schedule
    my_event_created
    ScheduleCSV.new.make_it
    sleep 2
    CoachPacket_AdminUI.goto_Coach_Packet_admin
    sleep 2
    select_event
    CoachPacket_AdminUI.import_event
    CoachPacket_AdminUI.upload_schedule_csv
    CoachPacket_AdminUI.upload_schedule
  end

  def log_into_Coach_Packet
    AthleticEventUI.adjust_window
    AthleticEventUI.login_with_password
  end

  def select_event_verify_schedule_upload
    AthleticEventUI.display_upcoming_events
    search_for_event
    open_event
    sleep 3
    my_roster_info
    select_schedule
    check_team1_name
    check_team2_name
    check_location
    select_teams
    check_team1_name
    check_team2_name
  end

  def test_schedule_csv
    create_athletic_event
    coach_packet_admin_upload_schedule
    sleep 4
    log_into_Coach_Packet
    select_event_verify_schedule_upload
  end
end
