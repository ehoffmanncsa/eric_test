# frozen_string_literal: true

require_relative '../test_helper'

require 'time'
require 'date'

# UI Test: upload csv and verify a note can be added to athlete
class AddAthleteNotesTest < Common
  def setup
    super

    @connection_client = AthleticEventServiceClient.new
    @athletic_event_data = athletic_event_data
    @expected_data = @athletic_event_data[:athletic_event]
    @event_name = @athletic_event_data[:athletic_event][:name]
    @coach_packet_config = Default.env_config['coach_packet']
    @email = @coach_packet_config['admin_username']
    @password = @coach_packet_config['admin_password']
    @notes = MakeRandom.lorem_words

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

    add_venue(@new_athletic_event['data']['id'])
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

  def open_note
    @browser.element("data-icon": 'plus').click
  end

  def add_note
    notes = @browser.element(id: 'notes-widget')
    notes.send_keys @notes
    sleep 2
  end

  def close_notes
    close_notes = @browser.element(text: 'Done')
    close_notes.click
  end

  def check_notes
    failure = []
    failure << "Notes #{@notes} not found" unless @browser.html.include? @notes
    assert_empty failure
  end

  def athlete_name_profile
    # gets the athlete name on the athlete profile page
    @display_athlete_name = @browser.element("data-automation-id": 'EventName').text
  end

  def search_athlete
    # verify that the athlete with the note displays on Tracked Athlete page
    failure = []
    failure << "Athlete #{@display_athlete_name} not found" unless @browser.html.include? @display_athlete_name
    assert_empty failure
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

  def verify_note_added_tracked_athlete
    AthleticEventUI.display_upcoming_events
    search_for_event
    open_event
    sleep 1
    AthleticEventUI.open_athlete_profile
    sleep 3
    open_note
    add_note
    close_notes
    sleep 3
    check_notes
    athlete_name_profile
    AthleticEventUI.select_hamburger_menu
    AthleticEventUI.select_tracked_athlete_page
    search_athlete
  end

  def test_roster_add_notes
    create_athletic_event
    coach_packet_admin_upload_roster
    sleep 2
    log_into_Coach_Packet
    verify_note_added_tracked_athlete
  end
end