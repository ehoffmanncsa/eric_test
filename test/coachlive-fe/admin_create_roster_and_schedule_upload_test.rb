# encoding: utf-8

require_relative '../test_helper'

require 'time'
require 'date'

# UI Test: upload csv that will create new client rms profiles
class AdminEventRMSTest < Common
  def setup
    super

   @coach_packet_config = Default.env_config['coach_packet']
   @email = @coach_packet_config['admin_username']
   @password = @coach_packet_config['admin_password']

   # generate new data
   RosterRMSCSV.new.make_it
   ScheduleCSV.new.make_it

   CoachPacket_AdminUI.setup(@browser)
   UIActions.fasttrack_login(@email, @password)
   CoachPacket_AdminUI.adjust_window_fasttrack
   CoachPacket_AdminUI.goto_Coach_Packet_admin
   CoachPacket_AdminUI.event_page
   CoachPacket_AdminUI.new_event

   @filler = CP::CoachPacketFiller.new(@browser)

   AthleticEventUI.setup(@browser)
  end

  def teardown
    super
  end

  def test_athletes_and_games
    do_preps
    select_event_verify_athletes_games
  end

  def select_event_verify_athletes_games
    AthleticEventUI.adjust_window
    AthleticEventUI.login_with_password
    AthleticEventUI.display_upcoming_events
    search_for_event
    AthleticEventUI.open_admin_event
    roster_info
    my_schedule_info
    sleep 2
    AthleticEventUI.select_teams_tab
    sleep 5
    check_team1_name
    check_team2_name
    AthleticEventUI.select_schedule_tab
    sleep 5
    check_team1_name
    check_team2_name
    AthleticEventUI.select_athletes_tab
    sleep 5
    check_name
  end

  private

  def do_preps
    fill_out_event
    gather_event_expected
    fill_out_venues
    coach_packet_admin_upload_schedule
    coach_packet_admin_upload_roster
  end

  def fill_out_event
    @filler.fill_out_cp_textfields
    @filler.fill_out_cp_datefields
    @filler.fill_out_cp_radiofields
    @filler.select_state
    @filler.select_sport
    @filler.select_event_operator
    @filler.submit
    CoachPacket_AdminUI.event_page

  end

  def fill_out_venues
    #add venue 1
    filter_event
    open_event
    CoachPacket_AdminUI.venue_page
    @filler.venue_data
    @filler.select_state
    CoachPacket_AdminUI.save_venue
    CoachPacket_AdminUI.event_page
    sleep 4
    filter_event
    open_event
    #add venue 2
    CoachPacket_AdminUI.venue_page
    @filler.venue_data2
    @filler.select_state
    CoachPacket_AdminUI.save_venue
    CoachPacket_AdminUI.event_page
    filter_event
    open_event
  end

  def coach_packet_admin_upload_schedule
    CoachPacket_AdminUI.import_event
    CoachPacket_AdminUI.upload_schedule_csv
    CoachPacket_AdminUI.upload_schedule
  end

  def coach_packet_admin_upload_roster
    CoachPacket_AdminUI.import_event
    CoachPacket_AdminUI.upload_roster_rms_csv
    CoachPacket_AdminUI.upload_athletes
  end

  def filter_event
    @browser.element(id: 'q_name_contains').send_keys @name
    @browser.button(name: 'commit').click
  end

  def open_event
    open_event = @browser.element(text: @name)
    open_event.click
    sleep 2
  end

  def gather_event_expected
    @name = @filler.name
    @website = @filler.website
    @logo_url = @filler.logo_url
    @registration_link = @filler.registration_link
    @age_range = @filler.age_range
    @description = @filler.description
    @contact_name = @filler.contact_name
    @contact_email = @filler.contact_email
    @city = @filler.city
  end

  def search_for_event
    search = @browser.element("data-automation-id": 'SearchBox')
    search.scroll.to
    @browser.text_field(type: 'text').set @name
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

  def my_schedule_info
    time = []; venue = []; location = []
    team1_name = []; team2_name = []
    file = CSV.read('schedule.csv'); file.shift
    file.each do |row|
      location << (row[7]).to_s
      time << (row[8]).to_s
      venue << (row[6]).to_s
      team1_name << "#{row[1]} #{row[0]}"
      team2_name << "#{row[3]} #{row[2]}"
    end

    @time = time
    @venue =  venue
    @location = location
    @team1_name = team1_name
    @team2_name = team2_name
  end

  def check_name
    failure = []
    @athlete_name.each do |athlete_name|
      failure << "Athlete name #{athlete_name} not found" unless @browser.html.include? athlete_name
    end
    assert_empty failure
  end

  def check_team1_name
    failure = []
    @team1_name.each do |team1_name|
      failure << "Team 1 name #{team1_name} not found" unless @browser.html.include? team1_name
    end
    assert_empty failure
  end

  def check_team2_name
    failure = []
    @team2_name.each do |team2_name|
      failure << "Team 2 name #{team2_name} not found" unless @browser.html.include? team2_name
    end
    assert_empty failure
  end
end
