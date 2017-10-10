# encoding: utf-8
require_relative '../../test/test_helper'
require 'securerandom'

# TS-38
# To add new recruit via Fasttrack and return his email and username
class FasttrackAddNewRecruit
  def initialize
    config = YAML.load_file('config/config.yml')
    username = config['admin']['username']
    password = config['admin']['password']
    @info = config['recruit']

    @ui = LocalUI.new(true)
    @browser = @ui.driver
    @wait = @ui.wait

    @username = "automation#{SecureRandom.hex(2)}"
  end

  def make_name
    charset = Array('a'..'z')
    Array.new(10) { charset.sample }.join
  end

  def make_number(digits)
    charset = Array('0'..'9')
    Array.new(digits) { charset.sample }.join
  end

  def goto_recruit_info_form
    @ui.fasttrack_login

    add = @browser.find_element(:xpath, '//*[@id="nav"]/li[1]')
    @browser.action.move_to(add).perform
    @browser.find_element(:link_text, 'Recruit').click

    raise '[ERROR] Cannot find Add/Recruit page' unless @browser.title =~ /Enter Recruit Information/
  end

  def fill_in_configs
    @wait.until { @browser.find_element(:id, 'footer').displayed? }
    %w[firstName lastName parent1FirstName parent1LastName].each do |attribute|
      @browser.find_element(:name, attribute).send_key make_name
    end

    %w[homePhonePh1 homePhonePh2 parent1PhonePh1 parent1PhonePh2].each do |attribute|
      @browser.find_element(:name, attribute).send_key make_number(3)
    end
    
    %w[homePhonePh3 parent1PhonePh3].each do |attribute|
      @browser.find_element(:name, attribute).send_key make_number(4)
    end
  end

  def select_dropdowns
    %w[primaryPhoneType parent1Relationship parent1PrimaryPhoneType
       scoutID rcUserID gender eventID highSchoolStateId sport highSchoolId].each do |attribute|
      sleep 0.1; list = @browser.find_element(:name, attribute);
      options = list.find_elements(:tag_name, 'option')
      options.shift
      options.sample.click
    end
  end

  def select_hs_grad_year(enroll_yr = nil)
    grad_yr = Time.now.year
    month = Time.now.month
    case enroll_yr
      when 'freshman'
        month > 6 ? grad_yr += 4 : grad_yr += 3
      when 'sophomore'
        month > 6 ? grad_yr += 3 : grad_yr += 2
      when 'junior'
        month > 6 ? grad_yr += 2 : grad_yr += 1
      when 'senior'
        month > 6 ? grad_yr += 1 : grad_yr
    end

    list = @browser.find_element(:name, 'highSchoolGradYear'); sleep 0.2
    options = list.find_elements(:tag_name, 'option')
    options.shift

    if enroll_yr.nil?
       options.sample.click; sleep 0.5
    else
      options.each { |opt| opt.click if (opt.text.to_i == grad_yr) }; sleep 0.5
    end
  end

  def select_attendee
    sleep 0.1; @browser.find_element(:class, 'mg-btm-1').location_once_scrolled_into_view; sleep 0.2
    attendees = @browser.find_elements(:name, 'eventAtendees')
    attendees.sample.click
  end

  def create_save_emails
    %w[emailPrimary parent1EmailPrimary].each do |email|
      @recruit_email = "#{@username}@ncsasports.org"
      @browser.find_element(:name, email).send_key @recruit_email

      if email.eql? 'emailPrimary'
        open('recruit_emails', 'a') { |f| f << "#{@recruit_email}," }
      end
    end
  end

  def main(enroll_yr = nil)
    goto_recruit_info_form
    fill_in_configs

    begin
      retries ||= 0
      select_dropdowns
      select_attendee
    rescue => e
      (retries += 1) < 3 ? retry : (puts e)
    end

    select_hs_grad_year(enroll_yr)
    create_save_emails

    btn = @browser.find_elements(:name, '/lead/Submit').last
    @browser.find_element(:id, 'footer').location_once_scrolled_into_view; sleep 0.2; btn.click; sleep 0.5
    @browser.close

    [@recruit_email, @username]
  end
end
