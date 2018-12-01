# encoding: utf-8
require_relative '../test_helper'

# TS-256: TED Regression
# UI Test: Update Coach User Details

=begin
  Update coach Tiffany Account Settings
  First make sure setting loads with correct info
  First name, last name, email are correct
  Send in new position and new phone number
  Make sure there is success message
  Make sure new position and phone number show after update
=end

class TEDUpdateCoachDetailsTest < Common
  def setup
    super
  end

  def teardown
    super
  end

  def test_update_coach_details
    UIActions.ted_login
    UIActions.wait_for_spinner

    @browser.link(:text, 'Account Settings').click; sleep 1
    Watir::Wait.until { @browser.div(:class, 'page-content').present? }

    # check info loading correctly
    firstname = @browser.text_field(:id, 'firstName')
    lastname = @browser.text_field(:id, 'lastName')
    email = @browser.text_field(:id, 'email')
    phone = @browser.text_field(:id, 'phone')
    position = @browser.text_field(:id, 'positionTitle')

    failure = []

    msg = "Incorrect first name #{firstname}"
    failure << msg unless firstname.attribute_value('value').eql? 'Tee'

    msg = "Incorrect last name #{lastname}"
    failure << msg unless lastname.attribute_value('value').eql? 'Rex'

    msg = "Incorrect email #{email}"
    failure << msg unless email.attribute_value('value').eql? 'ncsa.automation+ted@gmail.com'

    assert_empty failure

    # now make change, refresh page and check change
    new_phone = MakeRandom.number(10)
    new_position = MakeRandom.name

    phone.set new_phone
    position.set new_position

    @browser.button(:text, 'Update').click

    alert = @browser.div(:class, 'alert')
    assert_equal 'User information successfully updated.', alert.text, 'Incorrect success alert'

    @browser.refresh
    Watir::Wait.until { @browser.div(:class, 'page-content').present? }

    failure = []
    msg = "Incorrect phone number expected #{new_phone} vs #{phone}"
    failure << msg unless phone.attribute_value('value').eql? new_phone.to_s

    msg = "Incorrect position expected #{new_position} vs #{position}"
    failure << msg unless position.attribute_value('value').eql? new_position

    assert_empty failure
  end
end
