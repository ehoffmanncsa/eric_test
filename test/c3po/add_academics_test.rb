# encoding: utf-8
require_relative '../test_helper'

# C3PO Regression
# UI Test: Academics page
# Insert an email address at the bottom of this script, can be a free or prem user.
# If this script is rerun,  delete the transcript or the check_profile_history_gpa will fail.
class AddAcademicsInfoTest < Common
  def setup
    super

    C3PO.setup(@browser)
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
    @browser.textarea(:name, 'client_academic_data[honors_courses]').set 'I am honors classes text.'
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
    @browser.textarea(:name, 'client_academic_data[ap_courses]').set 'I am AP classes text.'
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
    @browser.textarea(:name, 'client_academic_data[academic_awards]').set "List any academic"+
    " achievements and/or awards:"

    aa2_form = @browser.element(:class, 'm-form-set')
    aa2_form.scroll.to
    @browser.textarea(:name, 'client_academic_data[extracurricular_notes]').set "List your"+
    " extracurricular (non sports related) activities:"
  end

  def save_record
    # save academics
    @browser.element(:name, 'commit').click;
  end

  def check_profile_history_gpa
    # go to Preview Profile and check gpa, transcript, sat and high school
    @browser.element(:class, 'button--primary').click;
    academics = @browser.elements(:class, %w[info-category scores])

    expected_academics = "ACADEMIC INFO\nGPA\n3.60  /  4.0\n View Transcript - This is my Transcript\nOther Notes:"+
    "\nCore GPA: 3.25/4.0 Weighted GPA: 3.54/5.0 Cumulative Class Rank: 199/400 Weighted Class Rank: 200/400"+
    "\nACT\n32 / 36\nOther Notes:\nI am some ACT notes\nSAT\n1221 / 1600\nOther Notes:\nI am some SAT notes"+
    "\nHigh School\nLane Tech High School\nEnrollment: 4278"
    assert_includes academics.first.text, expected_academics
  end

  def check_honors
    group_of_hon = @browser.elements(:class, %w[half accomplishments])

    expected_hon = "ACADEMIC ACCOMPLISHMENTS\nHonors Classes\nI am honors classes text.\nAP Classes\nI am AP classes"+
    " text.\nPreferred Field of Study\nBusiness\nRegistered with NCAA Eligibility Center\nYes"
    assert_includes group_of_hon.first.text, expected_hon
  end

  def check_accomplishments
    group_of_acc = @browser.elements(:class, %w[half awards])

    expected_aa = "AWARDS AND ACTIVITIES\nAcademic Awards:\nList any academic achievements and/or awards:\nExtracurricular"+
    " Notes:\nList your extracurricular (non sports related) activities:"
    assert_includes group_of_acc.first.text, expected_aa
  end

  def test_add_academics
    email = 'testf7ac@yopmail.com'
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
    check_honors
    check_accomplishments
  end
end
