# encoding: utf-8
require_relative '../test_helper'

# C3PO Regression
# UI Test: Key Stats
class AddKeyStatsTest < Common
  def setup
    super

    C3PO.setup(@browser)

    @Fourty_Yard_Dash = 5
    @Fourty_Yard_Dash_ver = 'Coach 40'
    @Fourty_Yard_Dash_date= '08/01/2018'
    @shuttle = 4.5
    @shuttle_ver = 'Coach Shuttle'
    @shuttle_date= '07/01/2018'
    @Bench_Press = 250
    @Bench_Press_ver = 'Coach Bench Press'
    @Bench_Press_date= '07/02/2018'
    @Squat = 300
    @Squat_ver = 'Coach Squat'
    @Squat_date= '07/03/2018'
    @Vertical = 28.0
    @Vertical_ver = 'Coach Vertical'
    @Vertical_date= '07/04/2018'
    @Cone_Drill = 7.5
    @Cone_Drill_ver = 'Coach Cone Drill'
    @Cone_Drill_date= '07/05/2018'
    @Broad_Jump = 124
    @Broad_Jump_ver = 'Coach Broad Jump'
    @Broad_Jump_date= '07/06/2018'

  end

  def teardown
    super
  end

  def primary_position_enter
    # primary position
    dropdown = @browser.element(:id, 'primary_position')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Quarterback'
    end
  end

  def physical_stats_enter
    # select height feet
    dropdown = @browser.element(:id, 'height_feet')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == '6'
    end

    # select height inches
    dropdown = @browser.element(:id, 'height_inches')
    options = dropdown.elements(:tag_name, 'option').to_a
    options.shift; options.sample.click

     options.each do |option|
      option.click if option.text == '11'
    end

    # select weight
    dropdown = @browser.element(:id, 'weight')
    options = dropdown.elements(:tag_name, 'option').to_a
    options.shift; options.sample.click

     options.each do |option|
      option.click if option.text == '300'
    end

    # select hand
    dropdown = @browser.element(:id, 'handed')
    options = dropdown.elements(:tag_name, 'option').to_a
    options.shift; options.sample.click

     options.each do |option|
      option.click if option.text == 'Right'
    end
  end

  def yard_dash_enter
    # add 40 yard dash
    @browser.text_field(:id, '40_Yard_Dash').set @Fourty_Yard_Dash

    @browser.text_field(:id, '40_Yard_Dash_verified').set @Fourty_Yard_Dash_ver

    @browser.text_field(:id, '40_Yard_Dash_date').set @Fourty_Yard_Dash_date

    dropdown = @browser.element(:id, '40_Yard_Dash_measurable_option')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Laser'
    end
  end

  def shuttle_enter
    # add 5-10-5 Shuttle
    @browser.text_field(:id, '5-10-5_Shuttle').set @shuttle

    @browser.text_field(:id, '5-10-5_Shuttle_verified').set @shuttle_ver

    @browser.text_field(:id, '5-10-5_Shuttle_date').set @shuttle_date

    dropdown = @browser.element(:id, '5-10-5_Shuttle_measurable_option')
    options = dropdown.elements(:tag_name, 'option').to_a

    options.each do |option|
      option.click if option.text == 'Hand'
    end
  end

  def bench_enter
    # add bench press
    @browser.text_field(:id, 'Bench_Press').set @Bench_Press

    @browser.text_field(:id, 'Bench_Press_verified').set @Bench_Press_ver

    @browser.text_field(:id, 'Bench_Press_date').set @Bench_Press_date
  end

  def squat_enter
    # add squat
    @browser.text_field(:id, 'Squat').set @Squat

    @browser.text_field(:id, 'Squat_verified').set @Squat_ver

    @browser.text_field(:id, 'Squat_date').set @Squat_date
  end

  def vertical_enter
    # add vertical
    @browser.text_field(:id, 'Vertical').set @Vertical

    @browser.text_field(:id, 'Vertical_verified').set @Vertical_ver

    @browser.text_field(:id, 'Vertical_date').set @Vertical_date
  end

  def cone_drill_enter
    # add vertical
    @browser.text_field(:id, '3_Cone_Drill').set @Cone_Drill

    @browser.text_field(:id, '3_Cone_Drill_verified').set @Cone_Drill_ver

    @browser.text_field(:id, '3_Cone_Drill_date').set @Cone_Drill_date
  end

  def broad_jump_enter
    # add broad_jump
    @browser.text_field(:id, 'Broad_Jump').set @Broad_Jump

    @browser.text_field(:id, 'Broad_Jump_verified').set @Broad_Jump_ver

    @browser.text_field(:id, 'Broad_Jump_date').set @Broad_Jump_date
  end

  def save_record
    # save key stats
    @browser.element(:name, 'commit').click;
  end


  def test_add_keystats
    email = 'test+1d5f@yopmail.com'
    UIActions.user_login(email)
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
  end
end
