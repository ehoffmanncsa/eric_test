# encoding: utf-8
#
# commom UI actions for Coach Live
module CoachPacket_AdminUI

  def self.setup(ui_object)
    @browser = ui_object
    @config = Default.env_config
  end

  def self.goto_Coach_Packet_admin
    @browser.element(text: 'Recruiting Dashboard').click
    sleep 2
    @browser.element(text: 'Coach Packet').click
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
