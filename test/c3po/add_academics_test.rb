# encoding: utf-8
require_relative '../test_helper'

# C3PO Regression
# Edit a premium client information on Academics page
# Verified the edited information is displayed on this person's profile page
# Static person used in this test case:
# username: ncsa.automation+38a2@gmail.com
# recruitinginfo email address: adriane.boyer@test.recruitinginfo.org

class V2AddAcademicsPremTest < Common
  def setup
    super

    @athlete_email = 'adriane.boyer@test.recruitinginfo.org'
    @filler = C3PO::AcademicsPageFiller.new(@browser)
    @profile_page = C3PO::AthleteProfilePage.new(@browser)
  end

  def teardown
    super
  end

  def test_academics_shows_on_profile_page
    do_preps
    gather_person_expected_academics
    goto_athlete_profile_page
    compare_academics_data_to_profile_page_data
  end

  private

  def fill_out_academics_page
    @filler.fill_out_highschool_information
    @filler.fill_out_textfields
    @filler.fill_out_textareas
    @filler.attach_transcript
    @filler.submit
  end

  def do_preps
    UIActions.user_login('ncsa.automation+38a2@gmail.com')
    UIActions.goto_academics
    fill_out_academics_page
  end

  def gather_person_expected_academics
    @overall_gpa = @filler.overall_gpa
    @transcript = @filler.transcript
    @core_gpa = @filler.core_gpa
    @weighted_gpa = @filler.weighted_gpa
    @class_rank = @filler.class_rank
    @class_size = @filler.class_size
    @weighted_class_rank = @filler.weighted_class_rank
    @weighted_class_rank_size = @filler.weighted_class_rank_size
    @sat_math = @filler.sat_math
    @sat_reading_writing = @filler.sat_reading_writing
    @sat_notes = @filler.sat_notes
    @sat_total = @sat_math + @sat_reading_writing
    @act_score = @filler.act_score
    @act_notes = @filler.act_notes
    @honors_courses = @filler.honors_courses
    @ap_courses = @filler.ap_courses
    @academic_awards = @filler.academic_awards
    @extracurricular_notes = @filler.extracurricular_notes
    @high_school_name = @filler.selected_high_school_name
  end

  def goto_athlete_profile_page
    @browser.element(class: 'button--primary').click
  end

  def compare_academics_data_to_profile_page_data
    failure = []

    failure << 'Incorrect high school selection' unless @profile_page.high_school.include?(expect_high_school_section)
    failure << 'Incorrect gpa section' unless expect_gpa_section == @profile_page.gpa_section
    failure << 'Incorrect sat section' unless expect_sat_section  == @profile_page.sat_section
    failure << 'Incorrect act section' unless expect_act_section  == @profile_page.act_section
    failure << 'Incorrect honors section' unless expect_honors_section == @profile_page.honors_section
    failure << 'Incorrect academics awards section' unless expect_academic_awards_section == @profile_page.academic_awards_section

    assert_empty failure
  end

  def expect_high_school_section
    "High School\n" + "#{@high_school_name}"
  end

  def expect_gpa_section
    "GPA\n" +
    "#{@overall_gpa}  /  4.0\n" +
    " View Transcript - #{@transcript}\n" +
    "Other Notes:\n" +
    "Core GPA: #{@core_gpa}/4.0 Weighted GPA: #{@weighted_gpa}/4.0 Cumulative Class Rank: #{@class_rank}/#{@class_size} Weighted Class Rank: #{@weighted_class_rank}/#{@weighted_class_rank_size}"
  end

  def expect_sat_section
    "SAT\n" +
    "#{@sat_total} / 1600\n" +
    "Other Notes:\n" +
    "#{@sat_notes}"
  end

  def expect_act_section
    "ACT\n" +
    "#{@act_score} / 36\n" +
    "Other Notes:\n" +
    "#{@act_notes}"
  end

  def expect_honors_section
    "ACADEMIC ACCOMPLISHMENTS\n" +
    "Honors Classes\n" +
    "#{@honors_courses}\n" +
    "AP/IB Classes\n" +
    "#{@ap_courses}\n" +
    "Registered with NCAA Eligibility Center\n" +
    "Yes"
  end

  def expect_academic_awards_section
    "AWARDS AND ACTIVITIES\n" +
    "Academic Awards:\n" +
    "#{@academic_awards}\n" +
    "Extracurricular Notes:\n" +
    "#{@extracurricular_notes}"
  end
end
