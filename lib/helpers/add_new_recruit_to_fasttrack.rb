# encoding: utf-8
require_relative '../../test/test_helper'
require 'securerandom'

# TS-38
# To add new recruit via Fasttrack
class FasttrackAddNewRecruit
  def initialize
    config = YAML.load_file('config/config.yml')

    username = config['admin']['username']
    password = config['admin']['password']
    @info = config['recruit']

    @ui = LocalUI.new(true)
    @browser = @ui.driver
    @wait = @ui.wait
  end

  def goto_recruit_info_form
    @ui.fasttrack_login

    add = @browser.find_element(:xpath, '//*[@id="nav"]/li[1]')
    @browser.action.move_to(add).perform
    @browser.find_element(:link_text, 'Recruit').click

    raise '[ERROR] Cannot find Add/Recruit page' unless @browser.title =~ /Enter Recruit Information/
  end

  def fill_in_static_configs
    @wait.until { @browser.find_element(:id, 'footer').displayed? }
    @info.each do |attribute, value|
      @browser.find_element(:name, attribute).send_key value
    end
    sleep 0.5
  end

  def select_dropdowns
    %w[gender eventID highSchoolStateId highSchoolId 
       sport highSchoolGradYear primaryPhoneType
       parent1Relationship parent1PrimaryPhoneType
       scoutID rcUserID].each do |attribute|
      sleep 0.3; list = @browser.find_element(:name, attribute); sleep 0.3
      options = list.find_elements(:tag_name, 'option')
      options.sample.click
    end
  end

  def select_attendee
    sleep 0.3; @browser.find_element(:class, 'mg-btm-1').location_once_scrolled_into_view; sleep 0.5
    attendees = @browser.find_elements(:name, 'eventAtendees')
    attendees.sample.click
  end

  def create_save_emails
    %w[emailPrimary parent1EmailPrimary].each do |email|
      addr = "automation#{SecureRandom.hex(2)}@ncsasports.org"
      @browser.find_element(:name, email).send_key addr

      if email.eql? 'emailPrimary'
        open('recruit_emails', 'a') { |f| f << "#{addr}," }
        @recruit_email = addr
      end
    end
  end

  def main
    goto_recruit_info_form
    fill_in_static_configs
    select_dropdowns

    begin
      select_attendee
    rescue => e
      select_attendee
    end

    create_save_emails

    btn = @browser.find_elements(:name, '/lead/Submit').last
    @browser.find_element(:id, 'footer').location_once_scrolled_into_view; sleep 0.1; btn.click

    raise "[ERROR] Not successfully added new recruit" unless @browser.current_url.include? "lead/GeneralInfoSubmit.do"
    @browser.quit

    @recruit_email
  end
end

#https://qa.ncsasports.org/fasttrack/lead/GeneralInfoSubmit.do
