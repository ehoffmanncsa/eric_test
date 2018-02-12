# encoding: utf-8
require_relative '../test_helper'

# TS-257: TED Regression
# UI Test: Invite Athlete via CSV
class InviteCSVAthletesTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    TED.setup(@browser)

    # generate new data to athletes.csv
    AtheteCSV.new.make_it
    @names = get_athlete_names
  end

  def teardown
    @browser.close
  end

  def get_athlete_names
    names = []
    file = CSV.read('athletes.csv'); file.shift
    file.each do |row|
      names << "#{row[0]} #{row[1]}"
    end

    names
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
      failure << "#{msg}" unless msg.text.include? 'Success'
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

    delete(row)
  end

  def delete(row)
    cog = row.elements(:tag_name, 'td').last.element(:class, 'fa-cog')
    cog.click; sleep 1
    modal = @browser.div(:class, 'modal-content')
    modal.button(:text, 'Delete').click
    small_modal = modal.div(:class, 'modal-content')
    small_modal.button(:text, 'Delete').click; sleep 1
  end

  def test_invite_athetes_csv
    UIActions.ted_coach_login
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
    # also delete that athlete to keep table clean
    # delete is done within check so we dont have to find row again
    @names.each do |name| 
      check_not_sent_status(name)
      refute (@browser.html.include? name), "Found deleted athlete #{name}"
    end
  end
end
