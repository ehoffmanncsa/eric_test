# encoding: utf-8
require_relative '../test_helper'

# C3PO Regression
# UI Test: Academics - must run this before My information or verification will be off...group of half has some arrays in the contact section
class AddAcademicsTest < Common
  def setup
    super

    C3PO.setup(@browser)
  end  

  def teardown
    super
  end


  def check_highschool
    @browser.element(:class, 'button--primary').click;
    group_of_half = @browser.elements(:class, %w[half mg-btm-1])

    i = 0
    group_of_half.each do |element|
      puts element.text
      puts i
      i += 1
    end

    expected_gpa = "GPA\n3.60  /  4.0\nOfficial Transcript - This is my Transcript\nOther Notes:\nCore GPA: 3.25/4.0 Weighted GPA: 3.54/5.0 Cumulative Class Rank: 199/400 Weighted Class Rank: 200/400"
    assert_includes group_of_half[1].text, expected_gpa

    expected_act = "ACT\n32 / 36\nOther Notes:\nI am some ACT notes"
    assert_includes group_of_half[2].text, expected_act

    expected_sat = "SAT\n1221 / 1600\nOther Notes:\nI am some SAT notes"
    assert_includes group_of_half[3].text, expected_sat

    expected_hs = 'Lane Tech High School'
    assert_includes group_of_half.last.text, expected_hs
  

    # remind Tiffany to talk about this
    # assert_includes @browser.element(:xpath, '//*[@id="scores-section"]/div/div[4]').text, 'Lane Tech High School'
  end

  


  def test_add_academics
    email = 'test+76d1@yopmail.com'
    UIActions.user_login(email)
    UIActions.goto_edit_profile

    C3PO.goto_academics



    check_highschool
    
  end
end  
