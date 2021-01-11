# frozen_string_literal: true

require_relative '../test_helper'

# UI Test: Sign up and go through onboarding
#This is quick smoke test of onboarding drill and here keystats and upload photo page will be skipped
#Note: detail test with verification of every onboarding page including keystats and photopage is added seperately
#This script will select random sports every time it runs

class SignupOnboardingTest < Common
  def setup
    super
    @zip = 60637
    @weight = 115
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]
    @firstname = post_body[:recruit][:athlete_first_name]

    @CoachEmail = MakeRandom.fake_email
    @CoachFirst = MakeRandom.first_name
    @CoachLast = MakeRandom.last_name
    @CoachCollege = MakeRandom.alpha
    @CoachPhone = MakeRandom.phone_number
    @CoachPosition = MakeRandom.name
    @teamname = 'sharpers'

    UIActions.user_login(@email)
    C3PO.setup(@browser)
    MSSetup.setup(@browser)
    MSSetup.set_password
  end

  def test_signup_goes_to_onboarding
    verify_client_at_onboarding
    onboarding_greets_client?
    click_parent_button
    verify_commitment_page
    click_next_on_commitment_page
    enter_zip_code
    choose_high_school
    submit_highschool_form
    select_gpa_scale(4)
    enter_gpa_correctvalue(3)
    submit_gpa_form
    choose_primary_position
    choose_secondary_position
    submit_position_form
    choose_height
    enter_weight
    submit_height_form
    skip_keystats
    skip_keystats
    enter_coach_info
    choose_coach_type
    select_team
    enter_team_name
    submit_team_form
  end


  def click_parent_button
    parent_button = @browser.element(class: 'MuiButton-label', text: "I'm a Parent")
    parent_button.click
    radiobutton = @browser.radio(name: 'commitmentLevel', value: '2')
    radiobutton.click
  end

  def verify_commitment_page
    failures = []
    failures << "commitment page doesn't display" unless @browser.url.include? '/clientrms/onboarding/commitment'
    assert_empty failures
  end

  def click_next_on_commitment_page
    submitbutton = @browser.element('type' => 'submit', 'form' => 'onboarding-commitment')
    submitbutton.click
  end

  def client_is_at_onboarding?
    @browser.url.include? '/clientrms/onboarding'
  end

  def verify_client_at_onboarding
    failures = []
    failures << "Client didn't land on onboarding after signup" unless client_is_at_onboarding?
    assert_empty failures
  end

  def client_is_at_dashboard?
    @browser.element(tag_name: 'body').classes.include? 'digital_dashboard'
  end

  def onboarding_greets_client?
    title = @browser.element(tag_name: 'h1')
    title.text.include? "Welcome to NCSA, #{@firstname}"
    failures = []
    failures << 'Onboarding failed to greet new client' unless title.text.include? "Welcome to NCSA, #{@firstname}"
    assert_empty failures
  end

  def enter_zip_code
    zip_input = @browser.element(name: 'zip')
    zip_input.to_subtype.clear
    zip_input.send_keys @zip
  end

  def choose_high_school
    #select_button = @browser.element(id: 'select-highSchoolId')
    select_button = @browser.element(id: "mui-component-select-highSchoolId")
    select_button.click

    menu_popover = @browser.element(id: 'menu-highSchoolId')
    options = menu_popover.elements('role' => 'option', 'aria-disabled' => 'false')

    options.to_a.sample.click
    sleep 1
  end

  def submit_highschool_form
    @browser.element('type' => 'submit', 'form' => 'onboarding-zip-and-high-school').click
    sleep 5
  end

  def select_gpa_scale(scale)
    #select_value = @browser.element(id: 'select-gpaScale').click
    select_value = @browser.element(id: "mui-component-select-gpaScale").click
    menu_popover = @browser.element(id: 'menu-gpaScale')
    options = menu_popover.element('data-value' => scale.to_s).click!
  end

  def enter_gpa_correctvalue(value)
    gpa_input = @browser.element(name: 'overallGpa')
    gpa_input.to_subtype.clear
    gpa_input.send_keys value
    # check next button  enabled after filling in info
    assert @browser.element('type' => 'submit', 'form' => 'onboarding-gpa').enabled?, 'Button not enabled after entering data'
    sleep 1
  end

  def submit_gpa_form
    @browser.element('type' => 'submit', 'form' => 'onboarding-gpa').click
    sleep 1
   end

  def choose_primary_position
    #select_button = @browser.element(id: 'select-primaryPositionId')
    select_button = @browser.element(id: "mui-component-select-primaryPositionId")
    select_button.click

    menu_popover = @browser.element(id: 'menu-primaryPositionId')
    options = menu_popover.elements('role' => 'option', 'aria-disabled' => 'false')
    selected_option = options.to_a.sample

    selected_option_value_pri_pos = selected_option.attribute_value('data-value')
    selected_option.click

    input_value_pri_pos = @browser.input(name: 'primaryPositionId').value
    assert_equal selected_option_value_pri_pos, input_value_pri_pos, "primary position dropdown does not work. Entered: #{selected_option_value_pri_pos}, but got #{input_value_pri_pos}"
    sleep 1
  end

  def choose_secondary_position
    select_button = @browser.element(id: "mui-component-select-secondaryPositionId")
    #select_button = @browser.element(id: 'select-secondaryPositionId')
    select_button.click

    menu_popover = @browser.element(id: 'menu-secondaryPositionId')
    options = menu_popover.elements('role' => 'option', 'aria-disabled' => 'false')
    selected_option = options.to_a.sample

    selected_option_value_sec_pos = selected_option.attribute_value('data-value')
    selected_option.click

    input_value_sec_pos = @browser.input(name: 'secondaryPositionId').value
    assert_equal selected_option_value_sec_pos, input_value_sec_pos, "secondary position dropdown does not work. Entered: #{selected_option_value_sec_pos}, but got #{input_value_sec_pos}"
    sleep 1
  end

  def submit_position_form
    @browser.element('type' => 'submit', 'form' => 'onboarding-positions').click
  end

  def skip_keystats
    skipbutton = @browser.button('data-test-id' => 'skip-link')
    skipbutton.click
    @browser.element(class: 'MuiButtonBase-root', tabindex: '0', role: 'button').click
    sleep 1
  end

  def enter_weight
    weight_input = @browser.element(name: 'weight')
    weight_input.to_subtype.clear
    weight_input.send_keys @weight

    sleep 2
  end

  def choose_height
    #select_button = @browser.element(id: 'select-height')
    select_button = @browser.element(id: "mui-component-select-height")
    select_button.click

    menu_popover = @browser.element(id: 'menu-height')
    options = menu_popover.elements('role' => 'option', 'aria-disabled' => 'false')

    selected_option = options.to_a.sample
    selected_option_value = selected_option.attribute_value('data-value')
    selected_option.click

    input_value = @browser.input(name: 'height').value
    assert_equal selected_option_value, input_value, "Height dropdown does not work. Entered: #{selected_option_value}, but got #{input_value}"

    sleep 1
  end

  def submit_height_form
    @browser.element('type' => 'submit', 'form' => 'onboarding-player-stats').click
    sleep 2
  end

  def enter_coach_info
    @browser.text_field(name: 'coachName').set @CoachFirst + @CoachLast
    @browser.text_field(name: 'coachPhone').set @CoachPhone
    @browser.text_field(name: 'coachEmail').set @CoachEmail
  end

  def choose_coach_type
    #select_button = @browser.element(id: 'select-coachType')
    select_button = @browser.element(id:"mui-component-select-coachType")
    select_button.click

    menu_popover = @browser.element(id: 'menu-coachType')
    options = menu_popover.elements('role' => 'option', 'aria-disabled' => 'false')

    options.to_a.sample.click
    sleep 1
  end

  def select_team
    hs_button = @browser.element(name: 'clubOrHighSchool', value: 'high_school')
    hs_button.click
   end

  def enter_team_name
    team_name = @browser.element(class: 'MuiInputBase-input', name: 'teamName')
    team_name.to_subtype.clear
    team_name.send_keys @teamname
 end

  def submit_team_form
    @browser.element('type' => 'submit', 'form' => 'onboarding-club-or-team').click
    sleep 3
  end
end
