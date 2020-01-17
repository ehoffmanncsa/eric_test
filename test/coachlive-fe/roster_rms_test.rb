# encoding: utf-8

require_relative '../test_helper'

require 'time'
require 'date'

# UI Test: upload csv that will create new client rms profiles
class RosterRMSCSVTest < Common
  def setup
    super

    @connection_client = AthleticEventServiceClient.new
    @athletic_event_data = athletic_event_data
    @expected_data = @athletic_event_data[:athletic_event]
    @event_name = @athletic_event_data[:athletic_event][:name]
    @coach_packet_config = Default.env_config['coach_packet']
    @email = @coach_packet_config['admin_username']
    @password = @coach_packet_config['admin_password']

    # generate new data to roster_create_rms.csv
    RosterRMSCSV.new.make_it
    @gmail = GmailCalls.new
    @gmail.get_connection

    CoachPacket_AdminUI.setup(@browser)
    UIActions.fasttrack_login(@email, @password)
    AthleticEventUI.setup(@browser)
  end

  def athletic_event_data
    {
      athletic_event: {
        access_type: "non-purchasable",
        age_range: MakeRandom.age_range,
        description: MakeRandom.lorem(rand(1 .. 4)),
        end_date: AthleticEventApi.date(rand(2 .. 4)),
        start_date: AthleticEventApi.date,
        name: MakeRandom.company_name,
        point_of_contact_email: MakeRandom.fake_email,
        point_of_contact_name: "#{MakeRandom.first_name}" + "#{MakeRandom.last_name}",
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
        {ncsa_id: 17638}
      ]
    }

  end

  def create_athletic_event
    @new_athletic_event = begin
                            retries ||= 0
                            @connection_client.post(
                              url: '/api/athletic_events/v1/athletic_events',
                              json_body: @athletic_event_data.to_json)
                          rescue => e
                            msg = "#{e} \nPOST body \n#{@athletic_event_data} \nGoing to retry"
                            puts msg; sleep 2
                            retry if (retries += 1) < 2
                          end

    add_venue(@new_athletic_event["data"]["id"])
  end

  def add_venue(athletic_event_id)
    venue = {
        athletic_event_id: athletic_event_id,
        address1: MakeRandom.address,
        address2: MakeRandom.address2,
        city: MakeRandom.city,
        country: 'USA',
        name: MakeRandom.name,
        state: MakeRandom.state,
        zip: MakeRandom.zip_code
    }

    begin
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

  def my_event_data
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

  def roster_info
    athlete_name = []; grad_year_position = []; jersey_number = [];
    org_team_name = []; state_code = [];
    file = CSV.read('roster_create_rms.csv'); file.shift
    file.each do |row|
      grad_year_position << "#{row[10]} #{row[2]}"
      athlete_name << "#{row[4]} #{row[5]}"
      jersey_number << "#{row[11]}"
      org_team_name << "#{row[17]} | #{row[15]} #{row[16]}"
      state_code << "#{row[17]}"
    end

    @grad_year_position = grad_year_position
    @athlete_name =  athlete_name
    @jersey_number = jersey_number
    @org_team_name = org_team_name
    @state_code = state_code
  end

  def check_name
    failure = []
    @athlete_name.each do |athlete_name|
      failure << "Athlete name #{athlete_name} not found" unless @browser.html.include? athlete_name
    end
    assert_empty failure
  end

  def check_grad_year_position
    failure = []
    @grad_year_position.each do |grad_year_position|
      failure << "Grad year and position #{grad_year_position} not found" unless @browser.html.include? grad_year_position
    end
    assert_empty failure
  end

  def check_state_org_team_name
    failure = []
    @org_team_name.each do |org_team_name|
      failure << "State, org and team name #{org_team_name} not found" unless @browser.html.include? org_team_name
    end
    assert_empty failure
  end

  def open_athlete_profile
    @browser.element("data-automation-id": 'AthleteName').click
  end

  def open_athlete_rms
    @browser.element("data-automation-id": 'EventLogo').click
  end

  def check_rms
    title = ' NCSA Client Recruiting Management System'
    assert_equal title, @browser.title, 'Incorrect page title'
  end

  def coach_packet_admin_upload_roster
    my_event_data
    sleep 2
    CoachPacket_AdminUI.goto_Coach_Packet_admin
    sleep 2
    select_event
    CoachPacket_AdminUI.import_event
    CoachPacket_AdminUI.upload_roster_rms_csv
    CoachPacket_AdminUI.upload_athletes
  end

  def log_into_Coach_Packet
    AthleticEventUI.adjust_window
    AthleticEventUI.request_login
    login_url = AthleticEventUI.get_login_url
    @browser.goto login_url
    sleep 1
    AthleticEventUI.delete_email
  end

  def select_event_verify_athletes_upload
    AthleticEventUI.display_upcoming_events
    search_for_event
    open_event
    roster_info
    sleep 1
    check_name
    check_grad_year_position
    check_state_org_team_name
    open_athlete_profile
    sleep 3
    open_athlete_rms
    sleep 3
    check_rms
    sleep 3
  end

  def test_roster_rms_csv
    create_athletic_event
    coach_packet_admin_upload_roster
    sleep 2
    log_into_Coach_Packet
    select_event_verify_athletes_upload
  end
end
