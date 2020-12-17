# frozen_string_literal: true

require_relative '../test_helper'

# MS Regression
# UI Test
# This script is to verify the pop-ups display correctly on the offerings page.
# using a static athlete

class PopupsOfferingsPage < Common
  def setup
    super

    UIActions.user_login('ncsa.automation+ab064d11@gmail.com', 'ncsa1333')
    MSSetup.setup(@browser)

    @covid19_popup = 'How to Approach Recruiting During Covid-19'
    @digital_recruiting_resources = 'Every membership includes:'
    @test_prep = 'Improve your score - Increase ACT by an average of 3 points and SAT by 120 points.'
  end

  def teardown
    super
  end

  def select_digital_recruiting_resources
    @browser.element(class: 'er-drawer-js').click; sleep 1
  end

  def open_covid19_video
    @browser.element(text: 'COVID-19: Bonus Skills Video Package').click; sleep 1
  end

  def open_custom_evaluation_session
    @browser.element(text: 'Custom Evaluation Session').click; sleep 1
  end

  def open_test_prep
    @browser.element('data-slug': 'package/method-test-prep').click; sleep 1
  end

  def close_pop_up
    @browser.element(class: 'mfp-close').click; sleep 2
  end

  def verify_digital_recruiting_resources_popup
    failure = []
    unless @browser.html.include? @digital_recruiting_resources
      failure << 'Digital Recruiting Resources pop-up not displaying'
    end
    assert_empty failure
  end

  def verify_covid19_popup
    failure = []
    failure << 'Covid19 pop-up not displaying' unless @browser.html.include? @covid19_popup
    assert_empty failure
  end

  def verify_custom_evaluation_session_popup
    failure = []
    failure << 'Sample Report not displaying' unless @browser.html.include? 'Sample Scouting Report'
    assert_empty failure
  end

  def verify_test_prep_popup
    failure = []
    failure << 'ACT/SAT pop-up not displaying' unless @browser.html.include? @test_prep
    assert_empty failure
  end

  def test_popups_on_offerings_page
    MSSetup.goto_offerings
    MSSetup.switch_to_premium_membership
    select_digital_recruiting_resources
    verify_digital_recruiting_resources_popup
    select_digital_recruiting_resources # closes pop-up
    open_covid19_video
    verify_covid19_popup
    close_pop_up
    open_custom_evaluation_session
    verify_custom_evaluation_session_popup
    close_pop_up
    open_test_prep
    verify_test_prep_popup
    close_pop_up
  end
end
