# encoding: utf-8
#
# commom UI actions for Coach Live
module CoachPacket_AdminUI

  def self.setup(ui_object)
    @browser = ui_object
    @config = Default.env_config
  end

  def self.adjust_window_fasttrack
    # adjust browser size
    width = 1500
    height = 1000
    @browser.window.resize_to(width, height)
  end

  def self.goto_Coach_Packet_admin
    @browser.element(text: 'Recruiting Dashboard').click
    sleep 2
    @browser.element(text: 'Coach Packet').click
  end

  def self.event_page
    @browser.element(text: 'Coach Packet Athletic Events').click
  end

  def self.new_event
    @browser.goto "https://qa.ncsasports.org/recruit/admin/new_athletic_event"
    sleep 3
  end

  def select_state
    dropdown = @browser.element(name: 'state')
    options = dropdown.elements(tag_name: 'option').to_a

    options.each do |option|
      option.click if option.value == 'IL'
    end
  end

  def select_sport
    dropdown = @browser.element(name: 'sports[]')
    options = dropdown.elements(tag_name: 'option').to_a

    options.each do |option|
      option.click if option.value == '17638'
    end
  end

  def select_event_operator
    dropdown = @browser.element(name: 'event_operator_id')
    options = dropdown.elements(tag_name: 'option').to_a

    options.each do |option|
      option.click if option.value == '9' #Zero Gravity
    end
    sleep 2
  end

  def self.save_event
    @browser.button(value: 'Create').click
  end

  def self.venue_page
    @browser.element(text: 'Add Venue').click
  end

  def self.save_venue
    @browser.button(value: 'Submit').click
  end

  def self.select_college_coach_page
    @browser.element(text: 'College Coaches').click
  end

  def self.import_event
    @browser.element(text: 'Import Event CSVs').click
    sleep 2
  end

  def self.upload_athletes
    @browser.element(value: 'Import Roster').click
    sleep 2
    @browser.element(text: 'Submit to RSS').click
    sleep 2
  end

  def self.upload_schedule
    @browser.element(value: 'Import Schedule').click
    sleep 2
  end

  def self.upload_rostermatch_csv
    path = File.absolute_path('rostermatch.csv')
    @browser.elements(id: 'coach_packet_athletic_event_file')[1].send_keys path
  end

  def self.upload_roster_rms_csv
    path = File.absolute_path('roster_create_rms.csv')
    @browser.elements(id: 'coach_packet_athletic_event_file')[1].send_keys path
  end

  def self.upload_roster_coach_packet_csv
    path = File.absolute_path('roster_coach_packet.csv')
    @browser.elements(id: 'coach_packet_athletic_event_file')[1].send_keys path
  end

  def self.upload_schedule_csv
    path = File.absolute_path('schedule.csv')
    @browser.elements(id: 'coach_packet_athletic_event_file')[0].send_keys path
  end

end
