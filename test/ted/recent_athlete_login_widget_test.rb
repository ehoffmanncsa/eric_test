require_relative '../test_helper'

# TS-568: recent athlete logins
# UI Test: RecentAthleteloginwidget
class RecentAthleteLoginWidget < Common
  def setup
    super

    @email = 'testae2d@yopmail.com'
    @firstname = 'Margery'
    @password = 'ncsa'

    @coach_email = 'coacheric.ted@gmail.com'
    @coach_password = 'ncsa'

    C3PO.setup(@browser)
    TED.setup(@browser)
  end
  def teardown
    super
  end

  def get_athlete_login_card
    @browser.elements(class: "athlete-login-card").find do |card_node|
      name_node = card_node.element(class: "athlete-login-card__name")
      name_node.html.include? @firstname
    end
  end

  def test_recent_athlete_login_widget
    failures = []

    # Login to clientrms as athlete (updating their last login date)
    UIActions.user_login(@email, @password)

    # Login to organization in TED containing athlete
    UIActions.ted_login(@coach_email, @coach_password)

    # Click on athlete's Recent Login Card
    # We do this because TED's data load is currently not perfect...
    # Going directly to the athlete's page will force the athlete's data to refresh
    get_athlete_login_card.click
    # We need to allow some time for the data to load
    sleep 2

    # Go back to the dashboard (now with athlete's data updated)
    TED.go_to_endpoint ""
    sleep 1

    # Grab the athlete's last login date
    last_login_date_text = get_athlete_login_card.element(class: "athlete-login-card__last-login-value").text

    # Get today's date (formatted in the same way as it appears in TED)
    todays_date_text = Time.now.strftime("%-m/%-d/%y")
    # Assert that the two dates are the same
    failures << "Recent athlete login date is not accurate" unless last_login_date_text == todays_date_text

    assert_empty failures
  end
end
