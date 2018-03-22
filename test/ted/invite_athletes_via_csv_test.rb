# encoding: utf-8
require_relative '../test_helper'

# TS-257: TED Regression
# UI Test: Invite Athlete via CSV

=begin
  Create a new csv file with new athlete records each time
  The number of records vary between 2 to 4 records
  Login as coach Joshua, upload the csv file by clicking Add Multiple Athletes
  Do a hard refresh then make sure all athlete's names are found in the table
  All athletes status remain Not Sent
  Delete athlete after done checking
  Make sure these names are not shown in UI anymore
=end

class InviteCSVAthletesTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    TED.setup(@browser)

    # generate new data to athletes.csv
    AtheteCSV.new.make_it
    @names, @emails = get_athlete_info
  end

  def teardown
    @browser.close
  end

  def get_athlete_info
    names = []; emails = []
    file = CSV.read('athletes.csv'); file.shift
    file.each do |row|
      names << "#{row[0]} #{row[1]}"
      emails << row[2]
    end

    [names, emails]
  end

  def upload_athletes
    # find add multiple athletes button and click
    @browser.button(:text, 'Add Multiple Athletes').click
    Watir::Wait.until { @browser.div(:class, 'modal-content').present? }

    # send in csv file path and upload it
    path = File.absolute_path('athletes.csv')
    modal = @browser.div(:class, 'modal-content')
    modal.element(:tag_name, 'input').send_keys path
    modal.button(:text, 'Upload').click

    # make sure all records are uploaded
    failure = []
    Watir::Wait.until { modal.element(:class, 'csv-message').present? }
    messages = modal.elements(:class, 'csv-message')
    assert_equal @names.length, messages.length, 'Not all athletes got uploaded'

    # make sure all uploads are successful
    messages.each do |msg|
      failure << "#{msg}" unless msg.text.match? 'Success'
    end
    assert_empty failure

    # finish the job
    modal.button(:text, 'Finished').click
  end

  def table
    @browser.table(:class, 'table--administration')
  end

  def check_not_sent_status(name)
    row = TED.get_row_by_name(table, name)
    status = row.elements(:tag_name, 'td')[4].text
    assert_equal status, 'Not Sent', "Expected status #{status} to be Not Sent"
  end

  def delete_athletes
    TEDAthleteApi.setup
    @emails.each do |email|
      athlete = TEDAthleteApi.get_athlete_by_email(email)
      TEDAthleteApi.delete_athlete(athlete['id'])
    end
  end

  def test_invite_athetes_csv
    UIActions.ted_login
    TED.go_to_athlete_tab

    upload_athletes
    TED.go_to_athlete_tab

    # make sure what uploaded are present
    failure = []
    @names.each do |name|
      failure << "Athlete name #{name} not found" unless @browser.html.include? name
    end
    assert_empty failure

    # make sure all new added athlete has not sent status
    @names.each do |name| 
      check_not_sent_status(name)
    end

    # delete athletes afterward to keep table clean
    delete_athletes
  end
end
