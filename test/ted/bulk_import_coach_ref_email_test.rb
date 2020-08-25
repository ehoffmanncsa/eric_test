# frozen_string_literal: true

require_relative '../test_helper'

# SALES-1654: TED Regression
# UI Test: Bulk Import with client has a coach_references record with the coach’s email

#   Coach_references record with the coach’s email will match, name and phone will not
#   In the TED with primary contact is the above coach, click Bulk Import
#   Athlete will display as pre-populated)
#   Athlete will be deleted from Ted
#   Bulk Import email can be slow, check Bulk Import folder in gmail to see if script worked

class BulkImportTedCoachEmail < Common
  def setup
    super
    TED.setup(@browser)
  end

  def teardown
    super
  end

  def bulk_import
    @browser.button(text: 'Bulk Import').click
  end

  def delete_athlete
    TED.delete_athlete(@athlete_name)
    refute (@browser.html.include? @athlete_name), "Found deleted athlete #{@athlete_name}"
  end

  def test_bulk_import_coach_email
    @athlete_name = 'Blair Gleichner'

    TED.impersonate_org(org_id = 2996)
    TED.go_to_athlete_tab
    bulk_import
    sleep 10

    failure = []
    begin
      five_minutes = 300 # seconds
      Timeout.timeout(five_minutes) do
        loop do
          html = @browser.html
          break if html.include? @athlete_name

          @browser.refresh
        end
      end
    rescue StandardError => e
      failure << 'Athlete not pre-populated after 2 minutes wait'
    end
    assert_empty failure

    delete_athlete
    sleep 5
    TED.check_bulk_import_email
  end
end
