# encoding: utf-8
require_relative '../test_helper'

# C3PO Regression
# UI Test: Academics - must run this before My information or verification will be off...group of half has some arrays in the contact section
class AddMyInformationTest < Common
  def setup
    super

    C3PO.setup(@browser)
  end  

  def teardown
    super
  end

  def add_tap
    # open event form
    @browser.link(:text, 'TAP Assessment Drill').click;

    @browser.element(:class, 'button--secondary button--wide').click;
    sleep 5

    @browser.window(title: 'TAP Plus with NCSA').use do
      @browser.button(:id, 'movenextbtn').scroll.to :center;
      @browser.button(:id, 'movenextbtn').click; sleep 5
      @browser.button(:id, 'movenextbtn').click; sleep 5
    end  
  end

  def check_highschool
    #@browser.element(:class, 'button--clear-dark').click;
    group_of_acc = @browser.elements(:class, %w[button--clear-dark])

    i = 0
    group_of_acc.each do |element|
      puts element.text
      puts i
      i += 1
    end
  

    # remind Tiffany to talk about this
    # assert_includes @browser.element(:xpath, '//*[@id="scores-section"]/div/div[4]').text, 'Lane Tech High School
  end
  

  def test_add_academics
    email = 'testc4b4@yopmail.com'
    UIActions.user_login(email)

    UIActions.goto_ncsa_university

    milestone = @browser.link(:text, 'Start getting noticed!').click
    @browser.element(:class, 'button--wide').click

    #add_tap
    check_highschool
  end
end  
