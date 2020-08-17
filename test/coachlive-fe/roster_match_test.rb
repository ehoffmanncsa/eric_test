# encoding: utf-8
require_relative '../test_helper'

require 'time'
require 'date'

# UI Test: upload csv that will match a client rms profile
class RosterMatchRMSTest < Common
  def setup
    super

    @connection_client = AthleticEventServiceClient.new
    @athletic_event_data = athletic_event_data
    @expected_data = @athletic_event_data[:athletic_event]
    @event_name = @athletic_event_data[:athletic_event][:name]
    @coach_packet_config = Default.env_config['coach_packet']
    @email = @coach_packet_config['admin_username']
    @password = @coach_packet_config['admin_password']

    # generate new data to rostermatch.csv
    RosterMatchCSV.new.make_it
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

  def get_my_event
    url = "/api/athletic_events/v1/athletic_events/#{@new_athletic_event['data']['id']}"
    @connection_client.get(url: url)
    @event_id = @new_athletic_event['data']['id']
  end

  def get_rss_email
    @gmail.mail_box = 'RSS'
    emails = @gmail.get_unread_emails
    @gmail.delete(emails) unless emails.empty?
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

  def get_roster_info
    athlete_name = []; grad_year_position = []; jersey_number = [];
    org_team_name = [];
    file = CSV.read('rostermatch.csv'); file.shift
    file.each do |row|
      grad_year_position << "#{row[5]} #{row[2]}"
      athlete_name << "#{row[3]} #{row[4]}"
      jersey_number << "#{row[6]}"
      org_team_name << "#{row[8]} #{row[9]}"
    end

    @grad_year_position = grad_year_position
    @athlete_name =  athlete_name
    @jersey_number = jersey_number
    @org_team_name = org_team_name
    @height = %q(6' 1", 140)
    @gpa = '3.8/4'
  end

  # do comparision
  def compare_my_info_data_to_athlete_profile_data
    failure = []
    failure << 'Incorrect jersey number' unless "#" + @jersey_number.shift.strip == AthleticEventUI.athlete_jersey_number
    failure << 'Incorrect athlete name' unless @athlete_name.shift.strip == AthleticEventUI.athlete_name
    failure << 'Incorrect grad year and postition' unless @grad_year_position.shift.strip == AthleticEventUI.grad_year_position
    failure << "Incorrect height/weight #{@height}" unless @browser.html.include? @height
    failure << "Incorrect GPA #{@gpa}" unless @browser.html.include? @gpa
    failure << 'Incorrect team and organization' unless "CA | " + @org_team_name.shift.strip == AthleticEventUI.team_org_info
    assert_empty failure
  end

  def check_rms
    title = " NCSA Client Recruiting Management System"
    assert_equal title, @browser.title, 'Incorrect page title'
  end

  def coach_packet_admin_upload_roster
    get_my_event
    sleep 2
    CoachPacket_AdminUI.goto_Coach_Packet_admin
    sleep 2
    select_event
    CoachPacket_AdminUI.import_event
    CoachPacket_AdminUI.upload_rostermatch_csv
    CoachPacket_AdminUI.upload_athletes
    get_rss_email
  end

  def log_into_Coach_Packet
    AthleticEventUI.adjust_window
    AthleticEventUI.login_with_password
  end

  def select_event_verify_athletes_upload
    AthleticEventUI.display_upcoming_events
    search_for_event
    open_event
    get_roster_info
    sleep 4
    compare_my_info_data_to_athlete_profile_data
    sleep 2
    AthleticEventUI.open_athlete_profile
    sleep 2
    AthleticEventUI.open_athlete_rms
    sleep 2
    check_rms
  end

  def test_roster_match_csv
    create_athletic_event
    coach_packet_admin_upload_roster
    sleep 2
    log_into_Coach_Packet
    select_event_verify_athletes_upload
  end
end
