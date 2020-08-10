# encoding: utf-8
require_relative '../test_helper'
require 'pry'

# UI Test: Verify keystats display as per the sport,and add the keystats on each text_field
class OnboardingkeystatsTest < Common
  def setup
    super

    @keystat1= 4.9
    @keystat2= 4.5
    @keystat3= 225
    @email = 'ncsa.automation+e6cc@gmail.com'
    UIActions.user_login(@email, 'ncsa1333')
    C3PO.setup(@browser)
    C3PO.goto_onboarding("key_stats")
  end

def test_keystats
  failures = []
  failures << "What's your 40 Yard Dash? key stat doesn't display" unless has_keystat?(0, "What's your 40 Yard Dash?")
  failures << "What's your 5-10-5 Shuttle? key stat doesn't display" unless has_keystat?(1, "What's your 5-10-5 Shuttle?")
  failures << "What's your Bench Press? key stat doesn't display" unless has_keystat?(2, "What's your Bench Press?")
  assert_empty failures
  enter_keystat1
  enter_keystat2
  enter_keystat3
end

  def has_keystat?(index, expected_label)
    keystat1 = form.labels[index]
    keystat1.text == expected_label
  end

  def enter_keystat1
    keystat1_input = @browser.element(name: "measurable0")
    keystat1_input.to_subtype.clear
    keystat1_input.send_keys @keystat1

    sleep 2
  end

  def enter_keystat2
    keystat1_input = @browser.element(name: "measurable1")
    keystat1_input.to_subtype.clear
    keystat1_input.send_keys @keystat2

    sleep 2
  end

  def enter_keystat3
    keystat1_input = @browser.element(name: "measurable2")
    keystat1_input.to_subtype.clear
    keystat1_input.send_keys @keystat3

    sleep 2
  end

  def form
    @browser.form(id: "onboarding-measurables")
  end

  def submit_form
   @browser.element("type" => "submit", "form" => "key_stats").click
  end
end
