require_relative '../test_helper'

# TS-569: correct roster modal behavior depending on athlete status
# UI Test: RosterModalAthleteStatusTest
class RosterModalAthleteStatusTest < Common
  def setup
    super

    @coach_email = 'brettnelson@yopmail.com'
    @coach_password = 'ncsa'

    TED.setup(@browser)
    UIActions.ted_login(@coach_email, @coach_password)
  end


  def teardown
    super
  end

  def test_roster_modal_on_dashboard
    athletes = []
    failures = []

    TED.go_to_athlete_tab
    @browser.element(class: "table--administration").elements(tag_name: "tr").each do |table_row|
      row_columns = table_row.elements(tag_name: "td")
      athletes.append({
        name: row_columns[0].text,
        invite_status: row_columns[4].text
      })
    end

    # Go back to dashboard
    TED.go_to_endpoint ""
    @browser.elements(class: "athlete-login-card").each do |login_card|
      athlete_name = login_card.element(class: "athlete-login-card__name").text
      athlete_data = athletes.find { |athlete| athlete[:name] == athlete_name }

      # Check that login cards are properly grayed out
      pending_statuses = ["Pending", "Not Sent"]
      if pending_statuses.include?(athlete_data[:invite_status])
        failures << "Pending or Not Sent athlete is not grayed out in recent login cards" unless login_card.class_name.include? "is-pending"

        login_card.click
        roster_modal = @browser.element(class: "roster-management-redirect-modal")
        failures << "Pending or Not Sent athlete card didn't open roster management modal" unless roster_modal.exists?
        roster_modal.element(class: "btn").click
        failures << "Roster management modal didn't redirect to roster management page" unless @browser.url.include? "roster"
        TED.go_to_endpoint ""
      end

      if athlete_data[:invite_status] == "Accepted"
        failures << "Accepted athlete is grayed out in recent login cards" if login_card.class_name.include? "is-pending"

        login_card.click
        failures << "Accepted athlete login card didn't redirect to athlete page" unless @browser.url.include? "athletes"
        TED.go_to_endpoint ""
      end
    end
  end
end
