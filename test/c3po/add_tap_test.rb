# encoding: utf-8
require_relative '../test_helper'

# TS-E1: C3PO Regression
# UI Test: Add TAP Test

class AddTAPTest < Common
  def setup
    super

    C3PO.setup(@browser)
  end

  def teardown
    super
  end

  def add_tap
    # open event form
    # need guardian, parent info and dob entered
    @browser.link(:text, 'TAP Assessment Drill').click
    @browser.element(:class, 'button--secondary button--wide').click sleep 5


    @browser.window(title: 'TAP Plus with NCSA').use do
      @browser.button(:id, 'movenextbtn').scroll.to :center;
      @browser.button(:id, 'movenextbtn').click; sleep 3
      @browser.button(:id, 'movenextbtn').click; sleep 3

      dropdown = @browser.element(:id, 'year299186X614X7594')
      options = dropdown.elements(:tag_name, 'option').to_a

      options.each do |option|
        option.click if option.text == '2000'
      end

     @browser.button(:id, 'movenextbtn').click;
     @browser.button(:id, 'movenextbtn').click;
     @browser.button(:id, 'movenextbtn').click;
     @browser.button(:id, 'movenextbtn').click;
     @browser.button(:id, 'movenextbtn').click; sleep 2
    end
  end

  def add_sport
    # open event form
    @browser.window(title: 'TAP Plus with NCSA').use do
      # @browser.checkbox(:id, 'answer299186X644X7811behavior1238').to_subtype.clear
      @browser.checkbox(:id, 'answer299186X644X7811behavior1238').click; sleep 1
      @browser.button(:id, 'movenextbtn').scroll.to :bottom;
      @browser.button(:id, 'movenextbtn').click;
      @browser.element(:id, 'answer299186X644X7923').to_subtype.clear
      @browser.element(:id, 'answer299186X644X7923').send_keys 'CoachFirst'
      @browser.button(:id, 'movenextbtn').click; sleep 1
      @browser.element(:id, 'answer299186X644X7929').to_subtype.clear
      @browser.element(:id, 'answer299186X644X7929').send_keys 'CoachLast'
      @browser.button(:id, 'movenextbtn').click; sleep 1
      @browser.element(:id, 'answer299186X644X7935').to_subtype.clear
      @browser.element(:id, 'answer299186X644X7935').send_keys 'coach@coach.com'
      @browser.button(:id, 'movenextbtn').click; sleep 1
      @browser.button(:id, 'movenextbtn').click; sleep 2
    end
  end

  def loop_1
   @browser.window(title: 'TAP Plus with NCSA').use do
      i = 0
      for i in 1 .. 86
        group_of_radio = @browser.elements(:type, 'radio').to_a
        group_of_radio.sample.click
        sleep 2
        i += 1
      end
    end
  end

  def add_tap1
    @browser.window(title: 'TAP Plus with NCSA').use do
      @browser.button(:id, 'movenextbtn').click; sleep 1
    end
  end

  def loop_2
   @browser.window(title: 'TAP Plus with NCSA').use do
      i = 0
      for i in 1 .. 15
        group_of_radio = @browser.elements(:type, 'radio').to_a
        group_of_radio.sample.click
        sleep 2
        i += 1
      end
    end
  end

  def add_tap2
    @browser.window(title: 'TAP Plus with NCSA').use do
      @browser.element(:id, 'answer299186X631X7726sNo').click;
      @browser.element(:id, 'answer299186X632X7727sNo').click; sleep 2
      @browser.button(:id, 'movenextbtn').click; sleep 2
      @browser.button(:id, 'movenextbtn').click; sleep 2
      @browser.element(:id, 'answer299186X616X7621').send_keys '0'
      @browser.button(:id, 'movenextbtn').click; sleep 2
      @browser.button(:id, 'movesubmitbtn').click; sleep 2
    end
  end

  def setup
    super

    C3PO.setup(@browser)
  end

  def verify_event
    # go to Preview Profile and check event
    subheader = @browser.element(:class, 'subheader')
    subheader.element(:id, 'tap_results_link').click
    @browser.element(:class, 'show-on-profile-checkbox').click; sleep 1
    subheader = @browser.element(:class, 'subheader')
    subheader.element(:id, 'edit_my_information_link').click
    @browser.element(:class, 'button--primary').click; sleep 1

    tap_results = @browser.elements(:class, 'info-category tap-assessment')
    expected_tap = 'TAP ATHLETIC TYPE'
    assert_includes tap_results.first.text, expected_tap
  end

  def test_do_tap
    email = 'test0f48@yopmail.com'
    UIActions.user_login(email)
    UIActions.goto_edit_profile

    C3PO.goto_tapresults

    add_tap
    add_sport
    loop_1
    add_tap1
    loop_2
    add_tap2
    UIActions.goto_edit_profile
    verify_event
  end
end
