# encoding: utf-8
require_relative '../test_helper'
require 'pry'


# UI Test: Test selecting onboarding position from a dropdown randomly amd verifies a value is selected and populated.
class OnboardingPositionTest < Common
  def setup
    super

    @zip = 60637

    @email = 'ncsa.automation+e6cc@gmail.com'
    UIActions.user_login(@email, 'ncsa1333')
    C3PO.setup(@browser)
    C3PO.goto_onboarding("position")
  end

  def test_enter_primary_secondary_pos
    choose_primary_position
    choose_secondary_position
    submit_form
  end


  def choose_primary_position
    select_button = @browser.element(id: "select-primaryPositionId")
    select_button.click

    menu_popover = @browser.element(id: "menu-primaryPositionId")
    options = menu_popover.elements("role" => "option", "aria-disabled" => "false")
    selected_option = options.to_a.sample

    selected_option_value_pri_pos = selected_option.attribute_value("data-value")
    selected_option.click

    input_value_pri_pos = @browser.input(name: "primaryPositionId").value
    assert_equal selected_option_value_pri_pos, input_value_pri_pos, "primary position dropdown does not work. Entered: #{selected_option_value_pri_pos}, but got #{input_value_pri_pos}"
    sleep 1
  end

  def choose_secondary_position
    select_button = @browser.element(id: "select-secondaryPositionId")
    select_button.click

    menu_popover = @browser.element(id: "menu-secondaryPositionId")
    options = menu_popover.elements("role" => "option", "aria-disabled" => "false")
    selected_option = options.to_a.sample

    selected_option_value_sec_pos = selected_option.attribute_value("data-value")
    selected_option.click

    input_value_sec_pos = @browser.input(name: "secondaryPositionId").value
    assert_equal selected_option_value_sec_pos, input_value_sec_pos, "secondary position dropdown does not work. Entered: #{selected_option_value_sec_pos}, but got #{input_value_sec_pos}"
    sleep 1
  end

  def submit_form
    @browser.element("type" => "submit", "form" => "onboarding-positions").click
  end
end
