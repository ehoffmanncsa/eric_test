# encoding: utf-8
require_relative '../test_helper'

# TS-289: C3PO Regression
# UI Test: Add Club Season
class AddClubSeasonTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]
    
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)

    POSSetup.setup(@ui)
    POSSetup.buy_package(@email, 'elite')
  end

  def teardown
    @browser.quit
  end

  def club_section
    @browser.find_element(:class, 'club_seasons')
  end

  def form
    @browser.find_element(:id, 'club_season_form_container')
  end

  def submit_form
    form.find_element(:class, 'submit').click
  end

  def check_incomplete_form_error_msg
    submit_form
    assert form.find_element(:class, 'errors'), 'Error banner not found'

    error_msg = form.find_element(:class, 'errors').text
    expected_msg = "Club Name cannot be blank.\n" + 'Year must be selected.'
    assert_equal expected_msg, error_msg, "Incorrect error message"
  end

  def fill_out_form
    url = 'https://chicago.suntimes.com/'
    path = File.absolute_path('test/c3po/cat.png')

    ['name', 'team_level', 'notes'].each do |name|
      form.find_element(:name, name).send_keys MakeRandom.name
    end

    # give jersey number
    # sometimes it doesnt show up so just ignore
    begin
      form.find_element(:name, 'jersey_number').send_keys MakeRandom.number(2)
    rescue; end

    form.find_element(:name, 'external_schedule_url').send_keys url
    form.find_element(:id, 'file').send_keys path
  end

  def select_year
    # select random year
    dropdown = form.find_element(:class, 'custom-select')
    dropdown.click
    years = dropdown.find_elements(:tag_name, 'option')
    years.shift; years.sample.click
  end

  def add_club
    fill_out_form
    select_year
    submit_form
  end

  def check_added_club
    boxes = club_section.find_elements(:class, 'box_list')
    refute_empty boxes, 'No box show up after added club'
  end

  def check_profile_history
    @browser.find_element(:class, 'button--primary').click
    UIActions.wait(40).until { @browser.find_element(:class, 'client-data').displayed? }
    history_section = @browser.find_element(:id, 'athletic-section')
    list = history_section.find_elements(:tag_name, 'li')
    refute_empty list, 'No club in history'

    list.sample.find_element(:class, 'mg-right-1').click; sleep 1
    msg = 'No popup clicking team Stats'
    assert @browser.find_element(:class, 'mfp-content'), msg
  end

  def test_add_club_season
    UIActions.user_login(@email)
    UIActions.goto_edit_profile

    # go to Athletics
    subheader = @browser.find_element(:class, 'subheader')
    subheader.find_element(:id, 'edit_athletic_link').click

    # open add club form
    club_section.find_element(:class, 'add_icon').click
    check_incomplete_form_error_msg
    add_club
    check_profile_history
  end
end