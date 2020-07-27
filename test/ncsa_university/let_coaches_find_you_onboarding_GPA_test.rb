# encoding: utf-8
require_relative '../test_helper'
require 'pry'

# UI Test: Test adding zip and high school with onboarding flow
class OnboardingGPATest < Common
  def setup
    super


    @email = 'ncsa.automation+e6cc@gmail.com'
    UIActions.user_login(@email, 'ncsa1333')
    C3PO.setup(@browser)
    C3PO.goto_onboarding("gpa")
   end


    def test_enter_gpa_scale_and_gpa
     select_gpa_scale(4)
     enter_gpa_incorrectvalue(8)
     err_msg_displayed
     check_error_message
     enter_gpa_correctvalue(3)
    end

   def test_enter_other_gpa_scale_and_gpa
     select_gpa_scale("other")
     enter_gpa_scale(100)
     enter_gpa_incorrectvalue(200)
     err_msg_displayed
     check_error_message
     enter_gpa_correctvalue(80)
     submit_form
   end

    def check_error_message
      failures = []
      failures << "error message doesn't display" unless err_msg_displayed
      assert_empty failures
    end

   def select_gpa_scale(scale)
      select_value = @browser.element(id: "select-gpaScale").click
      menu_popover = @browser.element(id: "menu-gpaScale")
      options = menu_popover.element("data-value" => "#{scale}").click!
   end

    def enter_gpa_scale(value)
      scale_input=@browser.element(name:"otherGpaScale")
      scale_input.to_subtype.clear
      scale_input.send_keys value
    end

    def enter_gpa_incorrectvalue(value)
      gpa_input = @browser.element(name: "overallGpa")
      gpa_input.to_subtype.clear
      gpa_input.send_keys value
    # check next button not enable before fill in info
      assert (@browser.element("type" => "submit", "form" => "onboarding-gpa").present?), 'Button enabled before entering data'
      sleep 2
    end

  def enter_gpa_correctvalue(value)
    gpa_input = @browser.element(name: "overallGpa")
    gpa_input.to_subtype.clear
    gpa_input.send_keys value
    # check next button  enabled after filling in info
    assert (@browser.element("type" => "submit", "form" => "onboarding-gpa").enabled?), 'Button not enabled after entering data'
  end

  def err_msg_displayed
    error_msg = @browser.element(class:"MuiFormHelperText-root")
    error_msg .text.include? "Your GPA is too high for the scale you entered"
    sleep 2
  end

  def submit_form
   @browser.element("type" => "submit", "form" => "onboarding-gpa").click
   end
end
