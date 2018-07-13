# encoding: utf-8
require_relative '../test_helper'

# C3PO Regression
# UI Test: Academics
class AddAcademicsTest < Common
  def setup
    super

    # _post, post_body = RecruitAPI.new.ppost
    # @email = post_body[:recruit][:athlete_email]

    C3PO.setup(@browser)
  

    @conf = 'City League'
    @conf_tran = 'This is my Transcript'
    @conf_cum_gpa =  3.60
    @conf_core_gpa = 3.25
    @conf_weighted_gpa  = 3.54
    @conf_rank = 199
    @conf_class_size = 400
    @conf_rank_weighted = 200
    @conf_class_size_weighted = 400
    @conf_math = 666
    @conf_reading = 555
    @conf_sat_2 = 750
    @conf_psat = 222
    @conf_sat_notes = 'I am some SAT notes'
    @conf_act = 32
    @conf_plan = 28
    @conf_act_notes = 'I am ACT Notes, I am retaking in the Spring'
    @conf_honors_details = 'I am honors details. The Presidents Honor Roll, published during Week 6 of the Fall and Spring semesters, is recognition of an undergraduate’s outstanding academic achievement that particular semester. Based on semester GPA, approximately the top 30 percent of all undergraduates receive this academic recognition. The GPA required to be on the Presidents Honor Roll varies each semester. The President’s Honor Roll designation is placed on the student’s academic transcript for the appropriate semester.'
    @conf_ap_details =  'At the end of sophomore year, I hesitated before registering for 11th-grade classes. Most of my choices had been obvious, and English should have been too — I had already received approval to take Advanced Placement English language and composition, a class I knew would impress colleges. But the honors English class my school offered also sounded enticing. In addition to the standard coursework, students in that class would write their own novels over the course of the year. The novels would be short and largely unpublishable, but learning about literature through hands-on experience seemed tailor-made for me.'
    @conf_aa_details =  'Accomplishments are relevant honors, achievements or awards that you earned for exceeding average standards in either academics, athletics, or in a work environment. Some examples of accomplishments are: Scholarships. ... Awards won for specific activities or subjects (i.e., Most Valuable Player (MVP), Fine Art Award'
    @conf_extra_details = 'Overall, I think that you have to find hobbies that you think they would enjoy or that are tailored toward their existing interests. If something doesnt work out, and theyve run the full course (some things such as cake decorating may just be a few weeks or months) then just think of it as nothing ventured, nothing gained, and look at other options. The main objective here is to get them out of the house to try new things and socialize. Some extra curricular activities may be costlier than others, but depending on where you live, your city may even offer affordable / free activities for youths and young adults. Additionally, a lot of area community colleges also offer youth enrichment programs at more affordable prices than private academies. '

  end

  def teardown
    super
  end

  # def hs_info_section
  #   @browser.element(:class, 'section')
  # end

  def hs_info_enter
    

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
    @browser.element(:id, 'high_school_conference').send_keys @conf
    
  end

  
  def transcript


    # add transcipt
  
    @browser.element(:class, 'add').click
    sleep 1

    academic_form = @browser.element(:class, 'academic-file-form')
    academic_form.scroll.to
    academic_form.text_field(:name, 'academic_file[notes]').send_keys @conf_tran
    
  

    path = File.absolute_path('test/c3po/cat.png')
    academic_form = @browser.element(:class, 'academic-file-form')
    academic_form.scroll.to
    academic_form.file_field(:name, 'academic_file[record]')
    academic_form.file_field(:class, 'file').set path


    @browser.element(:class, 'submit add button--primary').click
  end

  def grades
    

    #add grades Cumulative GPA
    @browser.text_field(:id, 'overall_gpa').set @conf_cum_gpa 
    

    dropdown = @browser.element(:id, 'gpa_scale')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == '4.0'
    end  
    
    #add grades Core GPA
    @browser.text_field(:id, 'core_gpa').set @conf_core_gpa 
    

    dropdown = @browser.element(:id, 'core_gpa_scale')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == '4.0'
    end

    #add grades Weighted GPA
    @browser.text_field(:id, 'weighted_gpa').set @conf_weighted_gpa
    

    dropdown = @browser.element(:id, 'weighted_scale')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == '5.0'
  end

  def class_rank

    #add class rank
    @browser.text_field(:id, 'class_rank').set @conf_rank

    @browser.text_field(:id, 'class_size').set @conf_class_size
    

    #add weighted class rank
    @browser.text_field(:id, 'weighted_class_rank').set @conf_rank_weighted

    @browser.text_field(:id, 'weighted_class_rank_size').set @conf_class_size_weighted
  end

  def sat

    #add sat

    sat_form = @browser.element(:class, 'm-form-set')
    sat_form.scroll.to
    @browser.text_field(:id, 'sat_math').set @conf_math

    @browser.text_field(:id, 'sat_reading').set @conf_reading

    @browser.text_field(:id, 'sat_2_score').set @conf_sat_2

    @browser.text_field(:id, 'psat_score').set @conf_psat

    @browser.text_field(:id, 'sat_notes').set @conf_sat_notes
    
  end

  def act

    #add act

    sat_form = @browser.element(:class, 'm-form-set')
    sat_form.scroll.to
    @browser.text_field(:id, 'act_score').set @conf_act

    @browser.text_field(:id, 'plan_score').set @conf_plan

    @browser.text_field(:id, 'act_notes').set @conf_act_notes
    
  end
  
  def honors
    

     # Honors Classes
    dropdown = @browser.element(:id, 'honors_courses_yn')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Yes'
    end
    sleep 2
   
    honors_form = @browser.element(:class, 'm-form-set')
    honors_form.scroll.to
    @browser.textarea(:name, 'client_academic_data[honors_courses]').set @conf_honors_details
  end  

  def ap
    

     # AP Classes
    dropdown = @browser.element(:id, 'ap_courses_yn')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Yes'
    end
    sleep 2
   
    ap_form = @browser.element(:class, 'm-form-set')
    ap_form.scroll.to
    @browser.textarea(:name, 'client_academic_data[ap_courses]').set @conf_ap_details
  end 

  def academic_accomplishment
    

     # AP Classes
    dropdown = @browser.element(:id, 'clearinghouse_yn')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Yes'
    end
    sleep 2
   
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
end


  def check_profile_history
    #go to Preview Profile
    @browser.element(:class, 'button--primary').click; sleep 1

    section =  @browser.element(:id, 'academic-section')
    academic_section = section.element(:id, 'scores-section')
  
    expected_gpa = '3.60  /  4.0'
    actual_gpa = @browser.element(:class, 'value').text
    msg = "GPA: #{actual_gpa} not as expected: #{expected_gpa}"
    assert_equal expected_gpa, actual_gpa, msg
  

    expected_trans = 'Official Transcript - This is my Transcript'
    actual_trans = @browser.element(:class, 'pd-btm-0').text
    msg = "Transcript text: #{actual_trans} not as expected: #{expected_trans}"
    assert_equal expected_trans, actual_trans, msg


    
  end

  def test_add_academics
    email = 'test660f245'
    UIActions.user_login(email)
    UIActions.goto_edit_profile

    C3PO.goto_academics

    hs_info_enter
    transcript
    grades
    class_rank
    sat
    act
    honors
    ap
    academic_accomplishment
    save_record
    check_profile_history
  end
end