# encoding: utf-8
require_relative '../test_helper'

# TS-274: C3PO Regression
# UI Test: Add Multiple High School Teams
class AddMultipleHSTeamsTest < Minitest::Test
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

  def add_hs_teams
    hs_section = @browser.find_element(:class, 'high_school_seasons')
    hs_section.find_element(:class, 'add_icon').click

    form = @browser.find_element(:id, 'high_school_season_form_container')
    dropdowns = form.find_elements(:class, 'custom-select')

    # select random year
    years_dropdown = dropdowns.first
    years_dropdown.click
    years = years_dropdown.find_elements(:tag_name, 'option')
    years.shift; years.sample.click

    # select random team
    teams_dropdown = dropdowns.last
    teams_dropdown.click
    teams = teams_dropdown.find_elements(:tag_name, 'option')
    teams.shift; teams.sample.click; sleep 0.5

    # click radio button and give jersey number
    # sometimes these 2 dont show up so just ignore them
    begin
      form.find_element(:name, 'season_team_info[starter]').click
      form.find_element(:name, 'season_team_info[jersey_number]').send_keys MakeRandom.number(2)
    rescue; end

    # add schedule file
    path = File.absolute_path('test/c3po/cat.png')
    upload_form = form.find_element(:id, 'schedule_upload_form')
    upload_form.find_element(:id, 'file').send_keys path
    form.send_keys :arrow_down

    # check boxes left table
    tables = form.find_elements(:class, 'athletic_awards')
    tables.each do |table|
      rows = table.find_elements(:tag_name, 'tr')
      rows.shift
      for i in 0 .. rows.length - 2
        rows[i].find_elements(:class, 'cb_award').sample.click
      end

      rows.last.find_element(:class, 'text_award').send_keys MakeRandom.name
    end
    
    #submit
    form.find_element(:class, 'submit').click; sleep 1
   end

  def check_added_teams
    teams_section = @browser.find_element(:class, 'high_school_seasons')
    boxes = teams_section.find_elements(:class, 'box_list')
    assert_equal 4, boxes.length, "#{boxes.length} box show up after adding 4 teams"
  end

  def check_profile_history
    @browser.find_element(:class, 'button--primary').click
    history_section = @browser.find_element(:id, 'athletic-section')
    list = history_section.find_elements(:tag_name, 'li')
    assert_equal 4, list.length, "#{list.length} teams in history - Expected 4"

    list.sample.find_element(:class, 'mg-right-1').click; sleep 1
    msg = 'No popup clicking team Stats'
    assert @browser.find_element(:class, 'mfp-content'), msg
  end

  def test_add_multiple_highschool_teams
    UIActions.user_login(@email)
    UIActions.goto_edit_profile

    # go to Athletics
    subheader = @browser.find_element(:class, 'subheader')
    subheader.find_element(:id, 'edit_athletic_link').click

    # add 4 HS teams
    for i in 1 .. 4
      add_hs_teams
    end
    
    check_added_team
    check_profile_history
  end
end
