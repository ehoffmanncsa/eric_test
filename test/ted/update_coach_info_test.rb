# encoding: utf-8
require_relative '../test_helper'

# TS-256: TED Regression
# UI Test: Update Coach User Details
class TEDUpdateCoachDetailsTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
  end

  def teardown
    @browser.close
  end

  def test_update_coach_details
    UIActions.ted_coach_login
    Watir::Wait.until { @browser.element(:class, 'graphs').present? }

    @browser.link(:text, 'Account Settings').click
    Watir::Wait.until { @browser.div(:class, 'page-content').present? }

    # check info loading correctly
    info_form = @browser.elements(:tag_name, 'form').first
    inputs = info_form.elements(:tag_name, 'input').to_a
    firstname = inputs[0].attribute_value('value')
    lastname = inputs[1].attribute_value('value')
    email = inputs[2].attribute_value('value')
    phone = inputs[3].attribute_value('value')
    position = inputs[4].attribute_value('value')

    failure = []
    msg = "Incorrect first name #{firstname}"
    failure << msg unless firstname.eql? 'Courtney'
    msg = "Incorrect last name #{lastname}"
    failure << msg unless lastname.eql? 'Dickson'
    msg = "Incorrect email #{email}"
    failure << msg unless email.eql? 'cdickson197@gmail.com'
    assert_empty failure

    # now make change, refresh page and check change
    new_phone = MakeRandom.number(10)
    new_position = MakeRandom.name
    inputs[3].set new_phone
    inputs[4].set new_position
    info_form.button(:text, 'Update').click

    alert = info_form.div(:class, 'alert')
    assert_equal 'User information successfully updated.', alert.text, 'Incorrect success alert'

    @browser.refresh
    Watir::Wait.until { @browser.div(:class, 'page-content').present? }
    phone = inputs[3].attribute_value('value')
    position = inputs[4].attribute_value('value')
    failure = []
    msg = "Incorrect phone number expected #{new_phone} vs #{phone}"
    failure << msg unless phone.eql? new_phone.to_s

    msg = "Incorrect position expected #{new_position} vs #{position}"
    failure << msg unless position.eql? position
    assert_empty failure
  end
end
