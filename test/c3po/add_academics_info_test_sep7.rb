# encoding: utf-8
require_relative '../test_helper'

# C3PO Regression
# UI Test: Academics page
class AddAcademicsInfoTest < Common
  def setup
    super

    C3PO.setup(@browser)

    @conf_honors_details = 'I am honors classes text.'
    @conf_ap_details = 'I am AP classes text.'
    @conf_aa_details = FFaker::Lorem.paragraph(9)
    @conf_extra_details = FFaker::Lorem.paragraph(10)
  end

  def teardown
    super
  end

  def select_high_school
    # select state
    dropdown = @browser.element(:id, 'high_school_state')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Illinois'
    end

    # select high school
    dropdown = @browser.element(:id, 'high_school_name')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Lane Tech High School'
    end

    # select division
    dropdown = @browser.element(:id, 'high_school_division')
    options = dropdown.elements(:tag_name, 'option').to_a
    options.shift; options.sample.click

    # fill out conf
    @browser.element(:id, 'high_school_conference').to_subtype.clear
    @browser.element(:id, 'high_school_conference').send_keys 'City League'
  end

  def attach_transcript
    # add transcipt
    @browser.element(:class, 'add').click
    sleep 1

    academic_form = @browser.element(:class, 'academic-file-form')
    academic_form.scroll.to
    academic_form.text_field(:name, 'academic_file[notes]').send_keys 'This is my Transcript'

    path = File.absolute_path('test/c3po/cat.png')
    academic_form = @browser.element(:class, 'academic-file-form')
    academic_form.scroll.to
    academic_form.file_field(:name, 'academic_file[record]')
    academic_form.file_field(:class, 'file').set path

    @browser.element(:class, 'submit add button--primary').click
  end

  def add_grades
    # add grades Cumulative GPA
    @browser.text_field(:id, 'overall_gpa').set 3.60

    dropdown = @browser.element(:id, 'gpa_scale')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == '4.0'
    end

    # add grades Core GPA
    @browser.text_field(:id, 'core_gpa').set 3.25

    dropdown = @browser.element(:id, 'core_gpa_scale')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == '4.0'
    end

    # add grades Weighted GPA
    @browser.text_field(:id, 'weighted_gpa').set 3.54

    dropdown = @browser.element(:id, 'weighted_scale')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == '5.0'
    end
  end

  def enter_class_rank
    # add class rank
    @browser.text_field(:id, 'class_rank').set 199

    @browser.text_field(:id, 'class_size').set 400

    # add weighted class rank
    @browser.text_field(:id, 'weighted_class_rank').set 200

    @browser.text_field(:id, 'weighted_class_rank_size').set 400
  end

  def add_sat
    # add sat

    sat_form = @browser.element(:class, 'm-form-set')
    sat_form.scroll.to
    @browser.text_field(:id, 'sat_math').set 666

    @browser.text_field(:id, 'sat_reading').set 555

    @browser.text_field(:id, 'sat_2_score').set 750

    @browser.text_field(:id, 'psat_score').set 222

    @browser.text_field(:id, 'sat_notes').set 'I am some SAT notes'
  end

  def add_act
    # add act
    act_form = @browser.element(:class, 'm-form-set')
    act_form.scroll.to
    @browser.text_field(:id, 'act_score').set 32

    @browser.text_field(:id, 'plan_score').set 28

    @browser.text_field(:id, 'act_notes').set 'I am some ACT notes'
  end

  def enter_honors
    # Honors Classes
    dropdown = @browser.element(:id, 'honors_courses_yn')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Yes'
    end
    sleep 1

    honors_form = @browser.element(:class, 'm-form-set')
    honors_form.scroll.to
    @browser.textarea(:name, 'client_academic_data[honors_courses]').set @conf_honors_details
  end

  def enter_ap
    # AP Classes
    dropdown = @browser.element(:id, 'ap_courses_yn')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Yes'
    end
    sleep 1

    ap_form = @browser.element(:class, 'm-form-set')
    ap_form.scroll.to
    @browser.textarea(:name, 'client_academic_data[ap_courses]').set @conf_ap_details
  end

  def enter_academic_accomplishment
    # AP Classes
    dropdown = @browser.element(:id, 'clearinghouse_yn')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Yes'
    end
    sleep 1

    aa1_form = @browser.element(:class, 'm-form-set')
    aa1_form.scroll.to
    @browser.textarea(:name, 'client_academic_data[academic_awards]').set @conf_aa_details

    aa2_form = @browser.element(:class, 'm-form-set')
    aa2_form.scroll.to
    @browser.textarea(:name, 'client_academic_data[extracurricular_notes]').set @conf_extra_details
  end

  def save_record
    # save academics
    @browser.element(:name, 'commit').click;
  end

  def check_profile_history_gpa
    # go to Preview Profile and check gpa and transcript
    @browser.element(:class, 'button--primary').click;
    academic_section = @browser.element(:id, 'academic-section').element(:id, 'scores-section')

    failure = [] # this is your empty array

    small_sections = academic_section.elements(:class, %w[score half mg-btm-1])

    expected_gpa = '3.60  /  4.0'
    actual_gpa = small_sections[0].element(:class, 'value').text
    msg = "GPA: #{actual_gpa} not as expected: #{expected_gpa}"
    failure << msg unless actual_gpa.eql? expected_gpa

    expected_trans = 'Official Transcript - This is my Transcript'
    actual_trans = small_sections[0].element(:class, 'pd-btm-0').text
    msg = "Transcript text: #{actual_trans} not as expected: #{expected_trans}"
    failure << msg unless actual_trans.eql? expected_trans

    expected_gpanotes = 'Other Notes:
Core GPA: 3.25/4.0 Weighted GPA: 3.54/5.0 Cumulative Class Rank: 199/400 Weighted Class Rank: 200/400'
    actual_gpanotes = small_sections[0].element(:class, %w[notes text--size-small]).text
    msg = "GPA Notes: #{actual_gpanotes} not as expected: #{expected_gpanotes}"
    failure << msg unless actual_gpanotes.eql? expected_gpanotes

    expected_act = '32 / 36'
    actual_act = small_sections[1].element(:class, 'value').text
    msg = "ACT: #{actual_act} not as expected: #{expected_act}"
    failure << msg unless actual_act.eql? expected_act

    expected_actnotes = 'Other Notes:
I am some ACT notes'
    actual_actnotes = small_sections[1].element(:class, %w[notes text--size-small]).text
    msg = "ACT Notes: #{actual_actnotes} not as expected: #{expected_actnotes}"
    failure << msg unless actual_actnotes.eql? expected_actnotes

    expected_sat = '1221 / 1600'
    actual_sat = small_sections[2].element(:class, 'value').text
    msg = "SAT: #{actual_sat} not as expected: #{expected_sat}"
    failure << msg unless actual_sat.eql? expected_sat

    expected_satnotes = 'Other Notes:
I am some SAT notes'
    actual_satnotes = small_sections[2].element(:class, %w[notes text--size-small]).text
    msg = "SAT Notes: #{actual_satnotes} not as expected: #{expected_satnotes}"
    failure << msg unless actual_satnotes.eql? expected_satnotes

    assert_empty failure
  end


  def test_add_academics
    email = 'test+790c@yopmail.com'
    UIActions.user_login(email)
    UIActions.goto_edit_profile

    C3PO.goto_academics

    select_high_school
    attach_transcript
    add_grades
    enter_class_rank
    add_sat
    add_act
    enter_honors
    enter_ap
    enter_academic_accomplishment
    save_record
    check_profile_history_gpa
  end
end
