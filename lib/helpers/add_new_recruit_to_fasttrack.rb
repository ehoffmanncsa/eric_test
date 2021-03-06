# encoding: utf-8
require_relative '../../test/test_helper'
require_relative 'make_random'

# TS-38
# To add new recruit via Fasttrack and return his email and username
class FasttrackAddNewRecruit < Common
  def initialize
    @recruit_email = MakeRandom.email
    @firstName = MakeRandom.first_name
    @lastName = MakeRandom.last_name
  end

  def setup
    super
  end

  def teardown
    super
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
    { 'eventID' => 'SAEF-AthletesWanted', #'TAKKLE Free RFEs',
      'primaryPhoneType' => 'My Mobile',
      'highSchoolStateId' => 'IL' }.each do |k, v|
      list = @browser.select_list(:name, k)
      list.select(v)
    end
  end

  def grad_year(enroll_yr = nil)
    grad_year = Time.now.year
    month = Time.now.month

    case enroll_yr
      when 'sophomore'
        month > 6 ? grad_year += 3 : grad_year += 2
      when 'junior'
        month > 6 ? grad_year += 2 : grad_year += 1
      when 'senior'
        month > 6 ? grad_year += 1 : grad_year
      else
        month > 6 ? grad_year += 4 : grad_year += 3
    end

    grad_year
  end

  def select_hs_grad_year(enroll_yr = nil)
    list = @browser.select_list(:name, 'highSchoolGradYear')
    list.click

    list.select grad_year(enroll_yr).to_s
  end

  def select_attendee
    attendees = @browser.radios(:name, 'eventAtendees').to_a
    attendees.sample.set
  end

  def select_birthday
    %w[month day year].each do |attr_name|
      list = @browser.select_list(:name, attr_name)
      list.click

      options = list.options.to_a

      if attr_name == 'year'
        list.select (grad_year - 17).to_s
      else
        list.select options.sample.text
      end
    end
  end

  def log_out
    @browser.link(:text, 'Log Out').click
  end

  def main(enroll_yr = nil)
    setup
    goto_recruit_info_form

    fill_in_configs
    select_attendee
    select_specials
    select_dropdowns
    select_hs_grad_year(enroll_yr)
    select_birthday

    # find submit button and click it then close browser
    tables = @browser.elements(:class, 'filter').to_a
    col = tables[2].elements(:tag_name, 'td').last
    btn = col.elements(:tag_name, 'input').last
    btn.click

    log_out

    [@recruit_email, @firstName, @lastName]
  end
end
