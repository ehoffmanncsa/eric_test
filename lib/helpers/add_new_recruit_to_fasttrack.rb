# encoding: utf-8
require_relative '../../test/test_helper'
require_relative 'make_random'

# TS-38
# To add new recruit via Fasttrack and return his email and username
class FasttrackAddNewRecruit
  def initialize
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)

    @recruit_email = "automation#{SecureRandom.hex(2)}@ncsasports.org"
    @firstName = MakeRandom.name; @lastName = MakeRandom.name
  end

  def goto_recruit_info_form
    UIActions.fasttrack_login

    nav_bar = @browser.element(:id, 'nav')
    list = nav_bar.elements(:tag_name, 'li')
    add = list.detect { |e| e.text == 'Add' }
    add.hover; add.link(:text, 'Recruit').click
    Watir::Wait.until { @browser.title =~ /Enter Recruit Information/ }
  end

  def fill_in_configs
    @browser.text_field(:name, 'firstName').set @firstName
    @browser.text_field(:name, 'lastName').set @lastName

    %w[parent1FirstName parent1LastName].each do |attr_name|
      @browser.text_field(:name, attr_name).set MakeRandom.name
    end

    %w[homePhonePh1 homePhonePh2 parent1PhonePh1 parent1PhonePh2].each do |attr_name|
      @browser.text_field(:name, attr_name).set MakeRandom.number(3)
    end
    
    %w[homePhonePh3 parent1PhonePh3].each do |attr_name|
      @browser.text_field(:name, attr_name).set MakeRandom.number(4)
    end
  end

  def select_dropdowns
    Watir::Wait.until { @browser.select_list(:name, 'highSchoolId').present? }
    %w[parent1Relationship parent1PrimaryPhoneType
       scoutID rcUserID gender sport highSchoolId].each do |attr_name|
      list = @browser.select_list(:name, attr_name); list.click
      options = list.options.to_a; options.shift
      list.select(options.sample.text)
    end
  end

  def select_specials
    # these dropdowns have too many special cases
    # selecting random is a bad idea
    # so select fix value
    { 'eventID' => 'TAKKLE Free RFEs',
      'primaryPhoneType' => 'My Mobile',
      'highSchoolStateId' => 'AB' }.each do |k, v|
      list = @browser.select_list(:name, k)
      list.select(v)
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

    list = @browser.element(:name, 'highSchoolGradYear'); list.click
    options = list.options.to_a; options.shift

    if enroll_yr.nil?
      options.sample.click
    else
      options.each { |opt| opt.click if opt.text == grad_yr.to_s }
    end
  end

  def select_attendee
    attendees = @browser.radios(:name, 'eventAtendees').to_a
    attendees.sample.set
  end

  def create_save_emails
    %w[emailPrimary parent1EmailPrimary].each do |email|
      @browser.text_field(:name, email).set @recruit_email

      if email.eql? 'emailPrimary'
        open('recruit_emails', 'a') { |f| f << "#{@recruit_email}," }
      end
    end
  end

  def main(enroll_yr = nil)
    goto_recruit_info_form
    fill_in_configs
    select_attendee
    select_specials
    select_dropdowns
    select_hs_grad_year(enroll_yr)
    create_save_emails

    # find submit button and click it then close browser
    tables = @browser.elements(:class, 'filter').to_a
    col = tables[2].elements(:tag_name, 'td').last
    btn = col.elements(:tag_name, 'input').last
    btn.click
    @browser.close

    [@recruit_email, @firstName, @lastName]
  end
end
