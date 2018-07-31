# encoding: utf-8
require_relative '../test_helper'

# C3PO Regression
# UI Test: My Information
class AddMyInformationTest < Common
  def setup
    super

    C3PO.setup(@browser)

    @firstname = 'FirstName'
    @mid_initial = 'J'
    @lastname = 'LastName'
    @suffix = 'II'
    @athlete_phone = '(312)555-1000'
    @athlete_secondary_phone = '(312)222-2000'
    @athlete_email = 'primary@yopmail.com'
    @secondary_email = 'secondary@yopmail.com'
    @guardian_first = 'Guardian1First'
    @guardian_lastname = 'Guardian1Last'
    @guardian1__phone = '(312)666-1000'
    @guardian1_secondary_phone = '(312)666-2000'
    @guardian1_email = 'guard1@yopmail.com'
    @guardian2_first = 'Guardian2First'
    @guardian2_lastname = 'Guardian2Last'
    @guardian2_phone = '(312)222-1000'
    @guardian2_secondary_phone = '(312)222-2000'
    @guardian2_email = 'guard2@yopmail.com'
    @address = '1333 N Kingsbury St'
    @address_cont = 'Suite 4'
    @city = 'Chicago'
    @zip = '60618'
    @facebook = 'https://www.facebook.com/NCSAsports/'
    @google = 'https://plus.google.com/102753321987437062065'
    @twitter = '@ncsa'
    @fieldofstudy = 'Business'
    @pers = 'A personal statement is a chance for admissions committees to get to know you.' \
    'I am open to different types of schools, although I would prefer one with a stable hierachy of coaches ' \
    'and courses in which I can major in political science. An environment in which I could learn from others ' \
    'and make an impact as soon as possible would be great. I will absolutely look through all opportunities ' \
    'even though higher echolon schools are prefered.'
  end

  def teardown
    super
  end

  def firstname_enter
    # fill out first name
    @browser.element(:id, 'first_name').to_subtype.clear
    @browser.element(:id, 'first_name').send_keys @firstname
  end

  def mid_initial_enter
    # fill out middle initial
    @browser.element(:id, 'middle_initial').to_subtype.clear
    @browser.element(:id, 'middle_initial').send_keys @mid_initial
  end

  def lastname_enter
    # fill out last name
    @browser.element(:id, 'last_name').to_subtype.clear
    @browser.element(:id, 'last_name').send_keys @lastname
  end

  def suffix_enter
    # fill out suffix
    @browser.element(:id, 'suffix').to_subtype.clear
    @browser.element(:id, 'suffix').send_keys @suffix
  end

  def hs_grad_year_enter
    # select grad year
    dropdown = @browser.element(:id, 'graduation_year')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == '2022'
    end

    # select dob month
    dropdown = @browser.element(:id, 'my_information_client_attributes_birth_date_2i')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'July'
    end

    # select dob day
    dropdown = @browser.element(:id, 'my_information_client_attributes_birth_date_3i')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == '4'
    end
    # select dob year
    dropdown = @browser.element(:id, 'my_information_client_attributes_birth_date_1i')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == '2000'
    end
  end

  def contact_enter
    # select Preferred Method of Contact
    dropdown = @browser.element(:id, 'preferred_contact_method')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Phone'
    end
  end

  def primary_phone_enter
    # fill out athlete_phone
    @browser.element(:id, 'athlete_phone').to_subtype.clear
    @browser.element(:id, 'athlete_phone').send_keys @athlete_phone

    # select Phone type
    dropdown = @browser.element(:id, 'primary_phone_type')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'My Mobile'
    end

    # select texts
    dropdown = @browser.element(:id, 'primary_phone_sms_yn')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Yes'
    end
  end

  def secondary_phone_enter
    # fill out athlete secondary phone
    @browser.element(:id, 'athlete_secondary_phone').to_subtype.clear
    @browser.element(:id, 'athlete_secondary_phone').send_keys @athlete_secondary_phone

    # select Phone type
    dropdown = @browser.element(:id, 'secondary_phone_type')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Home'
    end
  end

  def athlete_email_enter
    # fill out athlete email
    @browser.element(:id, 'athlete_email').to_subtype.clear
    @browser.element(:id, 'athlete_email').send_keys @athlete_email
  end

  def secondary_email_enter
    # fill out first name
    @browser.element(:id, 'secondary_email').to_subtype.clear
    @browser.element(:id, 'secondary_email').send_keys @secondary_email
  end

  def relationship_enter
    # select relationship for guardian 1
    dropdown = @browser.element(:id, 'parent1_relationship')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Mother'
    end
  end

  def guardian1_first_enter
    # fill out guradian first name
    @browser.element(:id, 'parent1_first_name').to_subtype.clear
    @browser.element(:id, 'parent1_first_name').send_keys @guardian_first
  end

  def guardian1_lastname_enter
    # fill out guardianlast name
    @browser.element(:id, 'parent1_last_name').to_subtype.clear
    @browser.element(:id, 'parent1_last_name').send_keys @guardian_lastname
  end

  def guardian1_phone_enter
    # fill out guardian primary phone
    @browser.element(:id, 'parent1_phone').to_subtype.clear
    @browser.element(:id, 'parent1_phone').send_keys @guardian1__phone

    # select Phone type
    dropdown = @browser.element(:id, 'parent1_primary_phone_type')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Mobile'
    end

    # select texts
    dropdown = @browser.element(:id, 'parent1_primary_phone_sms_yn')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Yes'
    end
  end

  def guardian1_phone2_enter
    # fill out guardian secondary phone
    @browser.element(:id, 'parent1_secondary_phone').to_subtype.clear
    @browser.element(:id, 'parent1_secondary_phone').send_keys @guardian1_secondary_phone

    # select Phone type
    dropdown = @browser.element(:id, 'parent1_secondary_phone_type')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Home'
    end
  end

  def guardian1_email_enter
    # fill out guardian 1 email 
    @browser.element(:id, 'parent1_email').to_subtype.clear
    @browser.element(:id, 'parent1_email').send_keys @guardian1_email
  end

  def relationship2_enter
    # select relationship for guradian 1
    dropdown = @browser.element(:id, 'parent2_relationship')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Father'
    end
  end

  def guardian2_first_enter
    # fill out guardian2 first name
    @browser.element(:id, 'parent2_first_name').to_subtype.clear
    @browser.element(:id, 'parent2_first_name').send_keys @guardian2_first
  end

  def guardian2_lastname_enter
    # fill out guardian2 last name
    @browser.element(:id, 'parent2_last_name').to_subtype.clear
    @browser.element(:id, 'parent2_last_name').send_keys @guardian2_lastname
  end

  def guardian2_phone_enter
    # fill out guardian2 primary phone
    @browser.element(:id, 'parent2_phone').to_subtype.clear
    @browser.element(:id, 'parent2_phone').send_keys @guardian2_phone

    # select Phone type
    dropdown = @browser.element(:id, 'parent2_primary_phone_type')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Mobile'
    end

    # select texts
    dropdown = @browser.element(:id, 'parent2_primary_phone_sms_yn')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Yes'
    end
  end

  def guardian2_phone2_enter
    # fill out guardian2 secondary phone
    @browser.element(:id, 'parent2_secondary_phone').to_subtype.clear
    @browser.element(:id, 'parent2_secondary_phone').send_keys @guardian2_secondary_phone

    # select Phone type
    dropdown = @browser.element(:id, 'parent2_secondary_phone_type')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Home'
    end
  end

  def guardian2_email_enter
    # fill out guardian 2 email 
    @browser.element(:id, 'parent2_email').to_subtype.clear
    @browser.element(:id, 'parent2_email').send_keys @guardian2_email
  end

  def address_enter
    # fill out address
    @browser.element(:id, 'address').to_subtype.clear
    @browser.element(:id, 'address').send_keys @address
  end

  def addresscont_enter
    # fill out address continued
    @browser.element(:id, 'unit').to_subtype.clear
    @browser.element(:id, 'unit').send_keys @address_cont
  end

  def city_enter
    # fill out city
    @browser.element(:id, 'city').to_subtype.clear
    @browser.element(:id, 'city').send_keys @city
  end

  def zip_enter
    # fill out zipcode
    @browser.element(:id, 'zip').to_subtype.clear
    @browser.element(:id, 'zip').send_keys @zip
  end


  def state_enter
    # select state
    dropdown = @browser.element(:id, 'state_selector')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'IL'
    end

  end

  def country_enter
    # select country before state
    dropdown = @browser.element(:id, 'country_selector')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'United States of America'
    end
  end

  def facebook_enter
    # fill out facebook
    @browser.element(:id, 'facebook').to_subtype.clear
    @browser.element(:id, 'facebook').send_keys @facebook
  end

  def google_enter
    # fill out google
    @browser.element(:id, 'googleplus').to_subtype.clear
    @browser.element(:id, 'googleplus').send_keys @google
  end

  def twitter_enter
    # fill out twitter
    @browser.element(:id, 'twitter').to_subtype.clear
    @browser.element(:id, 'twitter').send_keys @twitter
  end

  def fieldofstudy_enter
    # fill out Field of Study
    @browser.element(:id, 'preferred_major').to_subtype.clear
    @browser.element(:id, 'preferred_major').send_keys @fieldofstudy
  end

  def pers
    # fill out Personal Statement
    @browser.element(:class, 'froala-view froala-element not-msie f-basic').send_keys @pers
  end

  def save_record
    # save my information
    @browser.element(:name, 'commit').click;
    sleep 1
  end

  def test_add_my_information
    email = 'test01679241848'
    UIActions.user_login(email)
    UIActions.goto_edit_profile

    C3PO.goto_my_information

    firstname_enter
    mid_initial_enter
    lastname_enter
    suffix_enter
    hs_grad_year_enter
    contact_enter
    primary_phone_enter
    secondary_phone_enter
    athlete_email_enter
    secondary_email_enter
    relationship_enter
    guardian1_first_enter
    guardian1_lastname_enter
    guardian1_phone_enter
    guardian1_phone2_enter
    guardian1_email_enter
    relationship2_enter
    guardian2_first_enter
    guardian2_lastname_enter
    guardian2_phone_enter
    guardian2_phone2_enter
    guardian2_email_enter
    address_enter
    addresscont_enter
    city_enter
    zip_enter
    country_enter
    state_enter
    facebook_enter
    google_enter
    fieldofstudy_enter
    pers
    save_record
  end
end
