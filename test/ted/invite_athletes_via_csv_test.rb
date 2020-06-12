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

class InviteCSVAthletesTest < Common
  def setup
    super

    TED.setup(@browser)

    # generate new data to athletes.csv
    AtheteCSV.new.make_it
    @names, @emails = get_athlete_info
  end

  def teardown
    super
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
    @browser.button(text: 'Upload Roster').click
    Watir::Wait.until { TED.modal.present? }

    # send in csv file path and upload it
    path = File.absolute_path('athletes.csv')
    TED.modal.element(tag_name: 'input').send_keys path
    TED.modal.button(text: 'Upload').click; sleep 4

    # make sure all records are uploaded
    failure = []
    Watir::Wait.until { TED.modal.present? }
    messages = TED.modal.elements(class: 'csv-message')
    msg = "Not all athletes got uploaded. Expect #{@names.length}, See #{messages.length}"
    assert_equal @names.length, messages.length, msg

    # make sure all uploads are successful
    messages.each do |msg|
      failure << "#{msg}" unless msg.text.match? 'Success'
    end
    assert_empty failure

    # finish the job
    TED.modal.button(text: 'Finished').click
  end

  def check_not_sent_status(name)
    row = TED.get_row_by_name(name)
    status = row.elements(tag_name: 'td')[4].text
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
