# encoding: utf-8
require_relative '../test_helper'
require 'pry'

# TODO: Add TS test case
# UI Test: Test adding weight and choosing height with onboarding flow
class OnboardingHighSchoolTest < Common
  def setup
    super

    @weight = 115

    @email = 'ncsa.automation+e6cc@gmail.com'
    UIActions.user_login(@email, 'ncsa1333')
    C3PO.setup(@browser)
    C3PO.goto_onboarding("player_stats")
  end

  def test_enter_height_and_weight
     choose_height
     enter_weight
     submit_form
  end

  def enter_weight
    weight_input = @browser.element(name: "weight")
    weight_input.to_subtype.clear
    weight_input.send_keys @weight

    sleep 2
  end

  def choose_height
    select_button = @browser.element(id: "select-height")
    select_button.click

    menu_popover = @browser.element(id: "menu-height")
    options = menu_popover.elements("role" => "option", "aria-disabled" => "false")

    selected_option = options.to_a.sample
    selected_option_value = selected_option.attribute_value("data-value")
    selected_option.click

    input_value = @browser.input(name: "height").value
    assert_equal selected_option_value, input_value, "Height dropdown does not work. Entered: #{selected_option_value}, but got #{input_value}"

    sleep 1
  end

  def submit_form
    @browser.element("type" => "submit", "form" => "onboarding-player-stats").click
  end
end
