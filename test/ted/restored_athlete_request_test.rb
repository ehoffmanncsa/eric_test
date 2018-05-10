# encoding: utf-8
require_relative '../test_helper'

# TED-1413: create automation test for TED-1398

class RestoredAthleteRequestTest < Common
  def setup
    super
    TED.setup(@browser)

    TEDAthleteApi.setup

    @gmail = GmailCalls.new
    @gmail.get_connection
  end

  def teardown
    super
  end

  def store_accepted_athlete_info
    accepted_athletes = TEDAthleteApi.find_athletes_by_status('accepted')
    @athlete = accepted_athletes.sample
    refute @athlete['id'].nil?, 'No accepted athletes found'
  end

  def delete_athlete
    deleted_athlete = TEDAthleteApi.delete_athlete(@athlete['id'])
    assert deleted_athlete['attributes']['deleted'], 'Athlete not deleted successfully'
  end

  def add_athlete
    resp = TEDAthleteApi.add_athlete(create_athlete_request_body)
    @athlete = resp
    puts resp
    sleep 3
    assert resp['id'].present?, 'Adding athlete failed'
    assert resp['id'].present?, 'Adding athlete failed'
  end

  def create_athlete_request_body
    {
      data: {
        attributes: {
          email: athlete_email,
          first_name: @athlete['attributes']['profile']['first-name'],
          graduation_year: @athlete['attributes']['profile']['grad-year'],
          last_name: @athlete['attributes']['profile']['last-name'],
          phone: @athlete['attributes']['phone'],
          zip_code: @athlete['attributes']['zip-code'],
        },
        relationships: {
          team: { data: { type: 'teams', id: TEDTeamApi.get_random_team_id } }
        },
        type: 'athletes'
      }
    }.to_json
  end

  def athlete_email
    @athlete['attributes']['profile']['email']
  end

  def athlete_name
    profile = @athlete['attributes']['profile']

    "#{profile['first-name']} #{profile['last-name']}"
  end

  def send_invite_email
    TEDAthleteApi.send_invite_email(@athlete['id'])
  end

  def check_for_athlete_pop_up
    UIActions.user_login(athlete_email)

    assert @browser.element(:class, 'club-popup-js').present?, 'TED Invite Request Modal not appearing.'
  end

  def grant_access
    @browser.element(:id, 'club-yes').click
  end

  def check_athlete_has_status(status)
    UIActions.ted_login
    TED.go_to_athlete_tab

    athlete_row = @browser.element(:id, "athlete#{@athlete['id']}")
    assert (athlete_row.element(:text, athlete_email).present?), "Cannot find athlete: #{athlete_email}."
    assert (athlete_row.element(:text, status).present?), "Athlete #{athlete_email} is not listed as #{status}."
  end

  def check_and_clean_accepted_email
    @gmail.mail_box = 'Inbox'
    @gmail.subject = "#{athlete_name} has accepted your Team Edition request"
    emails = @gmail.get_unread_emails

    refute_empty emails, 'No accepted email found after athlete accepted invitation'

    @gmail.delete(emails)
  end

  def test_restore_athlete_with_request
    store_accepted_athlete_info
    delete_athlete
    add_athlete
    check_athlete_has_status('Pending')
    send_invite_email
    check_for_athlete_pop_up
    grant_access
    check_athlete_has_status('Accepted')
    check_and_clean_accepted_email
  end
end
