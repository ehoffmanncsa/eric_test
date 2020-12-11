# encoding: utf-8
require_relative '../test_helper'

# C3PO Regression
# UI Test: Key Stats
# Insert a new email at the bottom of this script.
# Must run add_hs_team_keystats_test.rb test to see key stats display on preview profile

class AddKeyStatsTestFree < Common
  def setup
    super

    C3PO.setup(@browser)
  end

  def teardown
    super
  end

  def primary_position_enter
    # primary position
    dropdown = @browser.element(id: 'primary_position')
    options = dropdown.elements(tag_name: 'option').to_a

    options.each do |option|
      option.click if option.text == 'Quarterback'
    end
  end

  def physical_stats_enter
    # select height feet
    dropdown = @browser.element(id: 'height_feet')
    options = dropdown.elements(tag_name: 'option').to_a

    options.each do |option|
      option.click if option.text == '6'
    end

    # select height inches
    dropdown = @browser.element(id: 'height_inches')
    options = dropdown.elements(tag_name: 'option').to_a
    options.shift; options.sample.click

     options.each do |option|
      option.click if option.text == '11'
    end

    # select weight
    dropdown = @browser.element(id: 'weight')
    options = dropdown.elements(tag_name: 'option').to_a
    options.shift; options.sample.click

     options.each do |option|
      option.click if option.text == '300'
    end

    # select hand
    dropdown = @browser.element(id: 'handed')
    options = dropdown.elements(tag_name: 'option').to_a
    options.shift; options.sample.click

     options.each do |option|
      option.click if option.text == 'Right'
    end
  end

  def yard_dash_enter
    # add 40 yard dash
    @browser.text_field(id: '40_Yard_Dash').set 5

    @browser.text_field(id: '40_Yard_Dash_verified').set 'Coach Fourty'

    @browser.text_field(id: '40_Yard_Dash_date').set '08/01/2018'

    dropdown = @browser.element(id: '40_Yard_Dash_measurable_option')
    options = dropdown.elements(tag_name: 'option').to_a

    options.each do |option|
      option.click if option.text == 'Laser'
    end
  end

  def shuttle_enter
    # add 5-10-5 Shuttle
    @browser.text_field(id: '5-10-5_Shuttle').set 4.5

    @browser.text_field(id: '5-10-5_Shuttle_verified').set 'Coach Shuttle'

    @browser.text_field(id: '5-10-5_Shuttle_date').set '07/01/2018'

    dropdown = @browser.element(id: '5-10-5_Shuttle_measurable_option')
    options = dropdown.elements(tag_name: 'option').to_a

    options.each do |option|
      option.click if option.text == 'Hand'
    end
  end

  def bench_enter
    # add bench press
    @browser.text_field(id: 'Bench_Press').set 250

    @browser.text_field(id: 'Bench_Press_verified').set 'Coach Bench Press'

    @browser.text_field(id: 'Bench_Press_date').set '09/01/2018'
  end

  def squat_enter
    # add squat
    @browser.text_field(id: 'Squat').set 500

    @browser.text_field(id: 'Squat_verified').set 'Coach Squat'

    @browser.text_field(id: 'Squat_date').set '09/01/2018'
  end

  def vertical_enter
    # add vertical
    @browser.text_field(id: 'Vertical').set 28.0

    @browser.text_field(id: 'Vertical_verified').set 'Coach Vertical'

    @browser.text_field(id: 'Vertical_date').set '07/04/2018'
  end

  def cone_drill_enter
    # add vertical
    @browser.text_field(id: '3_Cone_Drill').set 7.5

    @browser.text_field(id: '3_Cone_Drill_verified').set 'Coach Cone Drill'

    @browser.text_field(id: '3_Cone_Drill_date').set '07/04/2018'
  end

  def broad_jump_enter
    # add broad_jump
    @browser.text_field(id: 'Broad_Jump').set 124

    @browser.text_field(id: 'Broad_Jump_verified').set 'Coach Broad Jump'

    @browser.text_field(id: 'Broad_Jump_date').set '07/04/2018'
  end

  def save_record
    # save key stats
    @browser.element(value: 'Save').click;
  end

  def verify_header_info
    # go to Preview Profile and check Header info, email is verified in add my info script
    @browser.element(id: 'button--primary').click;
    header = @browser.elements(class: 'fullname')
    expected_header = " J. "
    assert_includes header.last.text, expected_header

    header_stats = @browser.elements(class: 'stats')
    expected_header_stats = "2022 Quarterback  •  6' 11\" 300lbs"
    assert_includes header_stats.last.text, expected_header_stats

    header_loc = @browser.elements(class: 'location')
    expected_header_loc = "Chicago, Illinois"
    assert_includes header_loc.last.text, expected_header_loc

    header_con = @browser.elements(class: 'contact')
    expected_header_con = "(802) 676-0642"
    assert_includes header_con.first.text, expected_header_con

    header_stats = @browser.elements(class: 'key-stats')
    expected_header_stats = "5\n40 Yard Dash\n4.5\n5-10-5 Shuttle\n250\nBench Press\n500\nSquat"
    assert_includes header_stats.first.text, expected_header_stats
  end

  def verify_keystats_history
    # go to Preview Profile and check key Stats History
    @browser.element(class: 'button--primary').click;
    ks = @browser.elements(id: 'ksh')

    expected_ks = "Key Stats History"
    assert_includes ks.first.text, expected_ks
  end

  def verify_keystats_40
    # go to Preview Profile and check 40 Yard Dash
    keystats_40 = @browser.elements(class: 'col th')
    expected_keystats_40 = "40 Yard Dash"
    assert_includes keystats_40.first.text, expected_keystats_40

    keystats_40val = @browser.elements(class: 'stat-val')
    expected_keystats_40val = '5'
    assert_includes keystats_40val.first.text, expected_keystats_40val

    keystats_40ver = @browser.elements(class: 'verified_info')
    expected_keystats_40ver = "Verified By: Coach Fourty\nVerified On: 08/01/2018"
    assert_includes keystats_40ver.first.text, expected_keystats_40ver
  end

  def verify_keystats_shuttle
    # go to Preview Profile and check 5-10-5 Shuttle
    keystats_shut = @browser.elements(class: 'col th')
    expected_keystats_shut = "5-10-5 Shuttle"
    assert_includes keystats_shut[1].text, expected_keystats_shut

    keystats_shutval = @browser.elements(class: 'stat-val')
    expected_keystats_shutval = '4.5'
    assert_includes keystats_shutval[1].text, expected_keystats_shutval

    keystats_shutver = @browser.elements(class: 'verified_info')
    expected_keystats_shutver = "Verified By: Coach Shuttle\nVerified On: 07/01/2018"
    assert_includes keystats_shutver[1].text, expected_keystats_shutver
  end

  def verify_keystats_bench
    # go to Preview Profile and check Bench Press
    keystats_bench = @browser.elements(class: 'col th')
    expected_keystats_bench = "Bench Press"
    assert_includes keystats_bench[2].text, expected_keystats_bench

    keystats_benchval = @browser.elements(class: 'stat-val')
    expected_keystats_benchval = '250'
    assert_includes keystats_benchval[2].text, expected_keystats_benchval

    keystats_benchver = @browser.elements(class: 'verified_info')
    expected_keystats_benchver = "Verified By: Coach Bench Press\nVerified On: 09/01/2018"
    assert_includes keystats_benchver[2].text, expected_keystats_benchver
  end

  def verify_keystats_squat
    # go to Preview Profile and check Squat
    keystats_squat = @browser.elements(class: 'col th')
    expected_keystats_squat= "Squat"
    assert_includes keystats_squat[3].text, expected_keystats_squat

    keystats_squatval = @browser.elements(class: 'stat-val')
    expected_keystats_squatval = '500'
    assert_includes keystats_squatval[3].text, expected_keystats_squatval

    keystats_squatver = @browser.elements(class: 'verified_info')
    expected_keystats_squatver = "Verified By: Coach Squat\nVerified On: 09/01/2018"
    assert_includes keystats_squatver[3].text, expected_keystats_squatver
  end

  def verify_keystats_vertical
    # go to Preview Profile and check Vertical
    keystats_vertical = @browser.elements(class: 'col th')
    expected_keystats_vertical= "Vertical"
    assert_includes keystats_vertical[4].text, expected_keystats_vertical

    keystats_verticalval = @browser.elements(class: 'stat-val')
    expected_keystats_verticalval = '28.0'
    assert_includes keystats_verticalval[4].text, expected_keystats_verticalval

    keystats_verticalver = @browser.elements(class: 'verified_info')
    expected_keystats_verticalver = "Verified By: Coach Vertical\nVerified On: 07/04/2018"
    assert_includes keystats_verticalver[4].text, expected_keystats_verticalver
  end

  def verify_keystats_cone
    # go to Preview Profile and check 3 Cone Drill
    keystats_cone = @browser.elements(class: 'col th')
    expected_keystats_cone= "3 Cone Drill"
    assert_includes keystats_cone[5].text, expected_keystats_cone

    keystats_coneval = @browser.elements(class: 'stat-val')
    expected_keystats_coneval = '7.5'
    assert_includes keystats_coneval[5].text, expected_keystats_coneval

    keystats_conever = @browser.elements(class: 'verified_info')
    expected_keystats_conever = "Verified By: Coach Cone Drill\nVerified On: 07/04/2018"
    assert_includes keystats_conever[5].text, expected_keystats_conever
  end

  def verify_keystats_jump
    # go to Preview Profile and check Broad Jump
    keystats_jump= @browser.elements(class: 'col th')
    expected_keystats_jump= "Broad Jump"
    assert_includes keystats_jump.last.text, expected_keystats_jump

    keystats_jumpval = @browser.elements(class: 'stat-val')
    expected_keystats_jumpval = '124'
    assert_includes keystats_jumpval.last.text, expected_keystats_jumpval

    keystats_jumpver = @browser.elements(class: 'verified_info')
    expected_keystats_jumpver = "Verified By: Coach Broad Jump\nVerified On: 07/04/2018"
    assert_includes keystats_jumpver.last.text, expected_keystats_jumpver
  end

  def test_add_keystats
    email = 'test788e@yopmail.com'
    UIActions.user_login_2(email)
    sleep 5
    UIActions.goto_edit_profile

    C3PO.goto_key_stats

    primary_position_enter
    physical_stats_enter
    yard_dash_enter
    shuttle_enter
    bench_enter
    squat_enter
    vertical_enter
    cone_drill_enter
    broad_jump_enter
    save_record
    #verify_header_info
    verify_keystats_history
    verify_keystats_40
    verify_keystats_shuttle
    verify_keystats_bench
    verify_keystats_squat
    verify_keystats_vertical
    verify_keystats_cone
    verify_keystats_jump
  end
end
