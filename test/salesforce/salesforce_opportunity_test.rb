# frozen_string_literal: true

require_relative '../test_helper'

# TS-: Salesforce Regression
# UI Test: Calendly meeting will create Salesforce opportunity and url will open client rms profile
class SalesforceOpportunityTest < Common
  def setup
    super
    @recruit_email, @athlete_first_name, @athlete_last_name, @client_id = Calendly.setup(@browser)
  end

  def teardown
    super
  end

  def open_opportunity_tab
    @browser.goto 'https://ncsa--fullsb.lightning.force.com/lightning/o/Opportunity/list?filterName=Recent'
    sleep 4
  end

  def confirm_opportunity(recruit_email)
    failure = []
    begin
      five_minutes = 300 # seconds
      Timeout.timeout(five_minutes) do
        loop do
          html = @browser.html
          break if html.to_s.include?(recruit_email)

          @browser.refresh
          sleep 3
        end
      end
    rescue StandardError => e
      puts "6:#{e.message}"
      puts e.backtrace
      failure << 'Opportunity does not display after 5 minutes wait'
    end
    assert_empty failure
  end

  def open_opportunity(athlete_first_name, athlete_last_name)
    @browser.element(title: "#{athlete_first_name} #{athlete_last_name}").click
    sleep 2
  end

  def open_client_rms_profile(client_id)
    @browser.element(href: "https://qa.ncsasports.org/clientrms/recruiting_profile_access/scout_login?client_id=#{client_id}").click
    sleep 5
  end

  def switch_browser_window
    # 2 browsers are open, need to switch to client rms
    @browser.window(title: 'NCSA Client Recruiting Management System').use
  end

  def confirm_client_rms_profile(athlete_first_name, athlete_last_name)
    failure = []
    begin
      five_minutes = 300 # seconds
      Timeout.timeout(five_minutes) do
        loop do
          html = @browser.html
          break if html.include? "#{athlete_first_name} #{athlete_last_name}"

          @browser.refresh
          sleep 3
        end
      end
    rescue StandardError => e
      failure << 'Client RMS profile does not display after 5 minutes wait'
    end
    assert_empty failure
  end

  def test_salesforce_opportunity
    UIActions.close_supercharge
    Calendly.select_schedule
    Calendly.select_parent
    Calendly.fill_out_calendly_form
    Calendly.schedule_event
    Calendly.schedule_close
    UIActions.fasttrack_login
    sleep 1
    UIActions.salesforce_login
    sleep 2
    open_opportunity_tab
    confirm_opportunity(@recruit_email)
    open_opportunity(@athlete_first_name, @athlete_last_name)
    open_client_rms_profile(@client_id)
    sleep 2
    switch_browser_window
    sleep 2
    confirm_client_rms_profile(@athlete_first_name, @athlete_last_name)
  end
end
