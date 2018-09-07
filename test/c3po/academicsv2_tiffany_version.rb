# encoding: utf-8
require_relative '../test_helper'

# C3PO Regression
# UI Test: Academics
class AddAcademicsTest < Common
  def setup
    super

    C3PO.setup(@browser)
  end

  def teardown
    super
  end

  def goto_profile
    # go to Preview Profile and check gpa and transcript
    @browser.element(:class, 'button--primary').click
  end

  def check_profile_history_gpa
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

  def check_highschool
    group_of_half = @browser.elements(:class, %w[half mg-btm-1])

    i = 0
    group_of_half.each do |element|
      puts element.text
      puts i
      i += 1
    end

    expected_hs = 'Lane Tech High School'
    assert_includes group_of_half.last.text, expected_hs

    # remind Tiffany to talk about this
    # assert_includes @browser.element(:xpath, '//*[@id="scores-section"]/div/div[4]').text, 'Lane Tech High School'
  end

  def check_academic_accomp
    #ACADEMIC ACCOMPLISHMENTS
    academic_section = @browser.element(:id, 'academic-section').element(:id, 'accomplishments-section')


    failure = [] # this is your empty array

    #aa_sections = academic_section.elements(:class, %w[text--size-small])


    expected_aa = 'I am honors classes text.'
    actual_aa = aa_sections[0].element(:class, 'text--strong').text
    msg = "aa: #{actual_aa} not as expected: #{expected_aa}"
    failure << msg unless actual_aa.eql? expected_aa

    expected_ap = 'I am AP classes text.'
    actual_ap = @browser.element(:h6, 'High School').text
    msg = "ap: #{actual_ap} not as expected: #{expected_ap}"
    failure << msg unless actual_ap.eql? expected_ap


    assert_empty failure
  end

  def check_hs
    # go to Preview Profile and check contact - this is all jacked, half mg-btm-1 is also used for hs name and enrollment
    #need to populate the actual contact name, email and phone from my info script
    academic_section = @browser.element(:id, 'scores-section').element(:class, %w[half mg-btm-1])

    failure = [] # this is your empty array


    expected_hs = 'Lane Tech High School'
    actual_hs = @browser.element(:h6, 'High School').text
    msg = "hs: #{actual_hs} not as expected: #{expected_hs}"
    failure << msg unless actual_hs.eql? expected_hs
 end

  def test_add_academics
    email = 'test+790c@yopmail.com'
    UIActions.user_login(email)
    UIActions.goto_edit_profile

    C3PO.goto_academics
    goto_profile


    check_profile_history_gpa
    check_highschool
    check_hs
  end
end
