# encoding: utf-8
require_relative '../test_helper'

# TED-1413: create automation test for TED-1398

class RestoredAthleteRequestTest < Common
  def setup
    super
    # POSSetup.setup(@browser)
    TED.setup(@browser)
  end

  def teardown
    super
  end

  def open_add_athlete_modal
    @browser.button(:text, 'Invite Athletes').click
    TED.modal.button(:text, 'Manually Add Athlete').click
    TED.modal.button(:text, 'Add Athlete').click; sleep 1
  end
  #
  #
  def send_invite_email
    # find and click the not sent button for the newly added athlete
    # make sure Edit Athlete modal shows up before proceeding
    row = @browser.element(:text, athlete_email).parent
    row.elements(:tag_name, 'td')[4].element(:class, 'btn-primary').click; sleep 1
    assert TED.modal.visible?, 'Edit Athlete modal not found'

    TED.modal.button(:text, 'Save & Invite').click
    UIActions.wait_for_modal

    # refresh the page and go back to athlete tab
    # make sure athlete status is now pending after email sent
    status = row.elements(:tag_name, 'td')[4].text
    assert_equal status, 'Pending', "Expected status #{status} to be Pending"
    TED.sign_out
  end

  def login_as_athlete_in_clientrms
    UIActions.user_login(athlete_email)
  end


  def store_accepted_athlete_info
    TEDAthleteApi.setup
    accepted_athletes = TEDAthleteApi.find_athletes_by_status('accepted')
    @athlete = accepted_athletes.sample
    refute @athlete['id'].nil?, 'No accepted athletes found'
  end

  def deactivate_athlete
    deleted_athlete = TEDAthleteApi.delete_athlete(@athlete['id'])
    assert deleted_athlete['attributes']['deleted'], 'Athlete not deleted successfully'
  end

  def athlete_email
    @athlete['attributes']['profile']['email']
  end

  def add_athlete
    TED.go_to_athlete_tab
    open_add_athlete_modal

    # fill out athlete form
    Watir::Wait.until { TED.modal.visible? }; sleep 1
    inputs = TED.modal.elements(:tag_name, 'input').to_a
    inputs[0].send_keys @athlete['attributes']['profile']['first-name']
    inputs[1].send_keys @athlete['attributes']['profile']['last-name']
    inputs[2].send_keys @athlete['attributes']['profile']['grad-year']
    inputs[3].send_keys @athlete['attributes']['zip-code']
    inputs[4].send_keys athlete_email
    inputs[5].send_keys @athlete['attributes']['phone']
    TED.modal.button(:text, 'Add Athlete').click
    UIActions.wait_for_modal

    # make sure athlete name shows up after added
    assert (@browser.element(:text, athlete_email).present?), "Cannot find newly added Athlete #{athlete_email}"
  end

  def test_restore_athlete_with_request
    store_accepted_athlete_info
    deactivate_athlete
    UIActions.ted_login
    add_athlete
    send_invite_email
    login_as_athlete_in_clientrms
    # grant_access
    # check_athlete_is_accepted
  end
end
