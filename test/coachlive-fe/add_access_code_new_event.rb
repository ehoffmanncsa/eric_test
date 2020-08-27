# frozen_string_literal: true

require_relative '../test_helper'
require 'time'
require 'date'
# UI Test: In this test a new event is created in fastrack UI and any random access_code is entered under "Access_type".
# Test verifies that coach is able to access the event in coachpacket app  by entering the same acees code entered in fasttrack.
class AddAcesscodeNewEvent < Common
  def setup
    super
    @connection_client = AthleticEventServiceClient.new
    @athletic_event_data = athletic_event_data
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
        access_type: 'access_code',
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
        { ncsa_id: 17638 }
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

  def coach_packet_admin_upload_roster
    my_event_data
    sleep 2
    CoachPacket_AdminUI.goto_Coach_Packet_admin
    sleep 2
    select_event
    sleep 2
    CoachPacket_AdminUI.enter_access_code
  end

  def log_into_Coach_Packet
    AthleticEventUI.adjust_window
    AthleticEventUI.login_with_password
  end

  def open_new_created_event
    AthleticEventUI.display_upcoming_events
    search_for_event
    open_event
    sleep 1
  end

  def check_access_code_dialogbox_display
    failures = []
    failures << "error message doesn't display" unless access_code_dialogbox_displayed
    assert_empty failures
  end

  def access_code_dialogbox_displayed
    error_msg = @browser.element(class: 'MuiDialogContent-root')
    error_msg .text.include? 'Enter Access code dialog box is displayed'
    sleep 1
  end

  def enter_access_code_cp
    @access_code_cp = 12345
    access_code_input_cp = @browser.element(class: 'MuiInputBase-input', placeholder: 'Access code')
    access_code_input_cp.send_keys @access_code_cp
    @browser.element(type: 'submit').click
    sleep 2
    failures = []
    failures << 'coach is unable to get in the event' unless event_displayed
    assert_empty failures
    end

  def event_displayed
    @browser.url.include? '/events/event/'
  end

  def test_add_access_code_new_event
    create_athletic_event
    sleep 5
    coach_packet_admin_upload_roster
    sleep 2
    log_into_Coach_Packet
    open_new_created_event
    check_access_code_dialogbox_display
    enter_access_code_cp
  end
end
