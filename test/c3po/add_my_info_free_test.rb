# encoding: utf-8
require_relative '../test_helper'

# C3PO Regression
# UI Test: My Information for free users only. Script wil create a free user.
# Script will also fill out and verify My Information page.
class AddMyInfoTestFree < Common
   def setup
    super

    # add a new freshman recruit, get back his email address
    @enroll_yr = 'freshman'
    _post, post_body = RecruitAPI.new(@enroll_yr).ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    @recruit_first_name = post_body[:recruit][:athlete_first_name]
    @recruit_last_name = post_body[:recruit][:athlete_last_name]
    @mom_first_name =  MakeRandom.first_name
    @dad_first_name =  MakeRandom.first_name
    @guardian_email1 = "test#{SecureRandom.hex(2)}@yopmail.com"
    @guardian_email2 = "test#{SecureRandom.hex(2)}@yopmail.com"
    @athlete_phone_home = post_body[:recruit][:athlete_phone]
    @athlete_phone_mobile = MakeRandom.phone_number
    @guard_phone_home1 = post_body[:recruit][:athlete_phone]
    @guard_phone_mobile1 = MakeRandom.phone_number
    @guard_phone_home2 = post_body[:recruit][:athlete_phone]
    @guard_phone_mobile2 = MakeRandom.phone_number

    # while process through the premium purchase process
    # also calculate expected membership and 1st payment
    add_free
    C3PO.setup(@browser)
  end

  def teardown
    super
  end

  def add_free
    POSSetup.setup(@browser)
    POSSetup.set_password(@recruit_email)
    UIActions.clear_cookies
  end

  def firstname_enter
    # fill out first name
    @browser.element(:id, 'first_name').to_subtype.clear
    @browser.element(:id, 'first_name').send_keys @recruit_first_name
  end

  def mid_initial_enter
    # fill out middle initial not used
    @browser.element(:id, 'middle_initial').to_subtype.clear
    @browser.element(:id, 'middle_initial').send_keys 'J'
  end

  def lastname_enter
    # fill out last name
    @browser.element(:id, 'last_name').to_subtype.clear
    @browser.element(:id, 'last_name').send_keys @recruit_last_name
  end

  def suffix_enter
    # fill out suffix not used
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
    @browser.element(:id, 'athlete_phone').send_keys @athlete_phone_mobile

    # select Phone type
    dropdown = @browser.element(:id, 'primary_phone_type')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Athlete Mobile'
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
    @browser.element(:id, 'athlete_secondary_phone').send_keys @athlete_phone_home

    # select Phone type
    dropdown = @browser.element(:id, 'secondary_phone_type')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Home'
    end
  end

  def athlete_email_enter
    # fill out athlete email --enter email here!!
    @browser.element(:id, 'athlete_email').to_subtype.clear
    @browser.element(:id, 'athlete_email').send_keys @recruit_email
  end

  def secondary_email_enter
    # fill out first name
    @browser.element(:id, 'secondary_email').to_subtype.clear
    @browser.element(:id, 'secondary_email').send_keys 'secondary@yopmail.com'
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
    @browser.element(:id, 'parent1_first_name').send_keys @mom_first_name
  end

  def guardian1_lastname_enter
    # fill out guardianlast name
    @browser.element(:id, 'parent1_last_name').to_subtype.clear
    @browser.element(:id, 'parent1_last_name').send_keys @recruit_last_name
  end

  def guardian1_phone_enter
    # fill out guardian primary phone
    @browser.element(:id, 'parent1_phone').to_subtype.clear
    @browser.element(:id, 'parent1_phone').send_keys @guard_phone_mobile1

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
    @browser.element(:id, 'parent1_secondary_phone').send_keys @guard_phone_home1

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
    @browser.element(:id, 'parent1_email').send_keys @guardian_email1
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
    @browser.element(:id, 'parent2_first_name').send_keys @dad_first_name
  end

  def guardian2_lastname_enter
    # fill out guardian2 last name
    @browser.element(:id, 'parent2_last_name').to_subtype.clear
    @browser.element(:id, 'parent2_last_name').send_keys @recruit_last_name
  end

  def guardian2_phone_enter
    # fill out guardian2 primary phone
    @browser.element(:id, 'parent2_phone').to_subtype.clear
    @browser.element(:id, 'parent2_phone').send_keys @guard_phone_mobile2

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
    @browser.element(:id, 'parent2_secondary_phone').send_keys @guard_phone_home2

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
    @browser.element(:id, 'parent2_email').send_keys @guardian_email2
  end

  def address_enter
    # fill out street address
    @browser.element(:id, 'address').to_subtype.clear
    @browser.element(:id, 'address').send_keys '1333 N Kingsbury St'
  end

  def addresscont_enter
    # fill out address continued
    @browser.element(:id, 'unit').to_subtype.clear
    @browser.element(:id, 'unit').send_keys 'Suite 4'
  end

  def city_enter
    # fill out city
    @browser.element(:id, 'city').to_subtype.clear
    @browser.element(:id, 'city').send_keys 'Chicago'
  end

  def zip_enter
    # fill out zipcode
    @browser.element(:id, 'zip').to_subtype.clear
    @browser.element(:id, 'zip').send_keys 60618
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
    @browser.element(:id, 'facebook').send_keys 'https://www.facebook.com/NCSAsports/'
  end

  def google_enter
    # fill out google
    @browser.element(:id, 'googleplus').to_subtype.clear
    @browser.element(:id, 'googleplus').send_keys 'https://plus.google.com/102753321987437062065'
  end

  def twitter_enter
    # fill out twitter
    @browser.element(:id, 'twitter').to_subtype.clear
    @browser.element(:id, 'twitter').send_keys '@ncsa'
  end

  def fieldofstudy_enter
    # fill out Field of Study
    @browser.element(:id, 'preferred_major').to_subtype.clear
    @browser.element(:id, 'preferred_major').send_keys 'Business'
  end

  def pers
    # fill out Personal Statement

    @browser.element(:class, 'froala-view froala-element not-msie f-basic').wd.clear
    @browser.element(:class, 'froala-view froala-element not-msie f-basic').send_keys 'A personal statement is a '+
    'chance for admissions committees to get to know you. I am open to different types of schools, although'+
    ' I would prefer one with a stable hierarchy of coaches. '
  end

  def save_record
    # save my information
    @browser.element(:name, 'commit').click;
    sleep 1
  end

  def verify_header_info
    # go to Preview Profile and check Header info
    @browser.element(:class, 'button--primary').click;
    header = @browser.elements(:class, 'fullname')
    expected_header = "#{@recruit_first_name} J. #{@recruit_last_name}"
    assert_includes header.last.text, expected_header

    header_stats = @browser.elements(:class, 'stats')
    expected_header_stats = "2022 Football"
    assert_includes header_stats.last.text, expected_header_stats

    header_loc = @browser.elements(:class, 'location')
    expected_header_loc = "Chicago, Illinois"
    assert_includes header_loc.last.text, expected_header_loc

    header_con = @browser.elements(:class, 'contact')
    expected_header_con = "#{@recruit_email}"+
    "  #{@athlete_phone_mobile}"
    assert_includes header_con.first.text, expected_header_con

  end

  def check_personal_statement
    # go to Preview Profile and check personal statement
    personal = @browser.elements(:class, %w[info-category personal-statement])

    expected_ps = "A personal statement is a chance for admissions committees"+
    " to get to know you. I am open to different types of schools, although I would prefer one with"+
    " a stable hierarchy of coaches. "
    assert_includes personal.first.text, expected_ps
  end

  def check_dob
    # go to Preview Profile and check personal statement
    dob = @browser.elements(:class, %w[date-of-birth])

    expected_dob = "07/04/2000"
    assert_includes dob.first.text, expected_dob
  end

  def check_profile_history_contact
    # go to Preview Profile and check athlete and guradian info, athlete first and last name not entered in this script
    group_of_half = @browser.elements(:class, %w[half mg-btm-1])

    expected_ath = "#{@recruit_first_name.upcase} J. #{@recruit_last_name.upcase} (Athlete)"+
    "\n#{@recruit_email}\n#{@athlete_phone_mobile} Athlete Mobile\n#{@athlete_phone_home} Home"
    assert_includes group_of_half[0].text, expected_ath

    expected_g1 = "#{@dad_first_name.upcase} #{@recruit_last_name.upcase} (Father)\n#{@guardian_email2}\n#{@guard_phone_mobile2}\n#{@guard_phone_home2} Home"
    assert_includes group_of_half[1].text, expected_g1

    expected_g2 = "#{@mom_first_name.upcase} #{@recruit_last_name.upcase} (Mother)\n#{@guardian_email1}\n#{@guard_phone_mobile1}\n#{@guard_phone_home1} Home"
    assert_includes group_of_half[2].text, expected_g2
  end

  def check_street_address
    # go to Preview Profile and check Mailing address
    street = @browser.elements(:class, %w[street-address])

    expected_street = '1333 N Kingsbury St'
    assert_includes street.first.text, expected_street
  end

  def check_city
    # go to Preview Profile and check Mailing city, state and zip
    city = @browser.elements(:class, %w[city])

    expected_city = 'Chicago, Illinois 60618'
    assert_includes city[1].text, expected_city
  end

  def check_social_links
    # go to Preview Profile and check socail links
    social = @browser.elements(:class, %w[list--inline])

    expected_social = "Facebook\n@ncsa\nGoogle+"
    assert_includes social.first.text, expected_social
  end

  def check_field_of_study
    # go to Preview Profile and check field of study
    field_of_study = @browser.elements(:class, %w[half accomplishments])

    expected_field_of_study = "Preferred Field of Study\nBusiness"
    assert_includes field_of_study.first.text, expected_field_of_study
  end

  def test_add_my_information
    #email = 'testd522@yopmail.com'

    UIActions.user_login(@recruit_email)
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
    twitter_enter
    fieldofstudy_enter
    pers
    save_record
    verify_header_info
    check_personal_statement
    check_profile_history_contact
    check_street_address
    check_city
    check_social_links
    check_field_of_study
  end
end
