# encoding: utf-8
require_relative '../test_helper'
require 'pry'

# TODO: Add TS test case
# UI Test: Test adding zip and high school with onboarding flow
class OnboardingHighSchoolTest < Common
  def setup
    super

    @zip = 60637

    @email = 'ncsa.automation+e6cc@gmail.com'
    UIActions.user_login(@email, 'ncsa1333')
    C3PO.setup(@browser)
    C3PO.goto_onboarding("location")
  end

  def test_enter_zip_and_highschool
    enter_zip_code
    choose_high_school
    submit_form
  end

  def enter_zip_code
    zip_input = @browser.element(name: "zip")
    zip_input.to_subtype.clear
    zip_input.send_keys @zip
  end

  def choose_high_school
    select_button = @browser.element(id: "mui-component-select-highSchoolId")
    select_button.click

    menu_popover = @browser.element(id: "menu-highSchoolId")
    options = menu_popover.elements("role" => "option", "aria-disabled" => "false")

    options.to_a.sample.click
    sleep 1
  end

  def submit_form
    @browser.element("type" => "submit", "form" => "onboarding-zip-and-high-school").click
  end
end
