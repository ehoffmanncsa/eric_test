# frozen_string_literal: true

require_relative '../test_helper'

# C3PO Regression
# Edit a premium client information on Key Stats page
# Verified the edited information is displayed on this person's profile page
# Static person used in this test case: test0b73@yopmail.com

class V2AddKeyStatsPremTest < Common
  def setup
    super
    @filler = C3PO::KeyStatsPageFiller.new(@browser)
    @profile_page = C3PO::AthleteProfilePage.new(@browser)
  end

  def teardown
    super
  end

  def test_key_stats_shows_on_profile_page
    UIActions.user_login('test0b73@yopmail.com', 'ncsa1333')
    UIActions.goto_key_stats
    fill_out_key_stats_page
    gather_person_expected_key_stats
    goto_athlete_profile_page
    compare_key_stats_data_to_profile_page_data
    verify_header_info
    verify_key_stats_header
  end

  private

  def fill_out_key_stats_page
    @filler.select_primary_position
    @filler.select_height_feet
    @filler.select_height_inches
    @filler.select_weight
    @filler.select_hand
    @filler.select_timing_fourty_yard_dash
    @filler.select_timing_five_ten_five
    @filler.fill_out_textfields
    @filler.submit
  end

  def gather_person_expected_key_stats
    @filler.fourty_yard_dash
    @filler.fourty_yard_dash_verified
    @filler.fourty_yard_dash_date
    @filler.five_ten_five_Shuttle
    @filler.five_ten_five_Shuttle_verified
    @filler.five_ten_five_Shuttle_date
    @filler.Bench_Press
    @filler.Bench_Press_verified
    @filler.Bench_Press_date
    @filler.Squat
    @filler.Squat_date
    @filler.Squat_verified
    @filler.Vertical
    @filler.Vertical_date
    @filler.Vertical_verified
    @filler.three_cone
    @filler.three_cone_verified
    @filler.three_cone_date
    @filler.Broad_Jump
    @filler.Broad_Jump_verified
    @filler.Broad_Jump_date
    @selected_primary_position = @filler.selected_primary_position
    @selected_height_feet = @filler.selected_height_feet
    @selected_height_inches = @filler.selected_height_inches
    @selected_weight = @filler.selected_weight
    @fourty_yard_dash = @filler.fourty_yard_dash
    @five_ten_five_Shuttle = @filler.five_ten_five_Shuttle
    @Bench_Press = @filler.Bench_Press
    @Squat = @filler.Squat
  end

  def goto_athlete_profile_page
    @browser.element(class: 'button--primary').click
    sleep 2
  end

  def compare_key_stats_data_to_profile_page_data
    failure = []

    unless @filler.fourty_yard_dash == @profile_page.keystats_40_yard_dash_time.to_f
      failure << 'Incorrect 40 yard dash time'
    end
    unless @filler.fourty_yard_dash_verified == @profile_page.keystats_40_yard_dash_verified_by
      failure << 'Incorrect 40 yard dash verified by'
    end
    unless @filler.fourty_yard_dash_date == @profile_page.keystats_40_yard_dash_verified_date
      failure << 'Incorrect 40 yard dash verified date'
    end
    unless @filler.five_ten_five_Shuttle == @profile_page.keystats_shuttle_time.to_f
      failure << 'Incorrect 5-10-5 shuttle time'
    end
    unless @filler.five_ten_five_Shuttle_verified == @profile_page.keystats_shuttle_time_verified_by
      failure << 'Incorrect 5-10-5 shuttle time verfied by'
    end
    unless @filler.five_ten_five_Shuttle_date == @profile_page.keystats_shuttle_time_verified_date
      failure << 'Incorrect 5-10-5 shuttle verified date'
    end
    unless @filler.Bench_Press == @profile_page.keystats_bench_press_weight.to_f
      failure << 'Incorrect Bench Press weight'
    end
    unless @filler.Bench_Press_verified == @profile_page.keystats_bench_press_verified_by
      failure << 'Incorrect Bench Press weight verfied by'
    end
    unless @filler.Bench_Press_date == @profile_page.keystats_bench_press_verified_date
      failure << 'Incorrect Bench Press weight verified date'
    end
    failure << 'Incorrect Squat weight' unless @filler.Squat == @profile_page.keystats_squat_weight.to_f
    unless @filler.Squat_verified == @profile_page.keystats_squat_verified_by
      failure << 'Incorrect Squat weight verfied by'
    end
    unless @filler.Squat_date == @profile_page.keystats_squat_verified_date
      failure << 'Incorrect Squat weight verified date'
    end
    failure << 'Incorrect Vertical' unless @filler.Vertical == @profile_page.keystats_vertical.to_f
    unless @filler.Vertical_verified == @profile_page.keystats_vertical_verified_by
      failure << 'Incorrect Vertical verfied by'
    end
    unless @filler.Vertical_date == @profile_page.keystats_vertical_verified_date
      failure << 'Incorrect Vertical verified date'
    end
    failure << 'Incorrect Three Cone Time' unless @filler.three_cone == @profile_page.keystats_three_cone.to_f
    unless @filler.three_cone_verified == @profile_page.keystats_three_cone_verified_by
      failure << 'Incorrect Three Cone Time verfied by'
    end
    unless @filler.three_cone_date == @profile_page.keystats_three_cone_verified_date
      failure << 'Incorrect Three Cone Time verified date'
    end
    failure << 'Incorrect Broad_Jump Distance' unless @filler.Broad_Jump == @profile_page.keystats_broad_jump.to_f
    unless @filler.Broad_Jump_verified == @profile_page.keystats_broad_jump_verified_by
      failure << 'Incorrect Broad_Jump Distance verfied by'
    end
    unless @filler.Broad_Jump_date == @profile_page.keystats_broad_jump_verified_date
      failure << 'Incorrect Broad_Jump Distance verified date'
    end

    assert_empty failure
  end

  def verify_header_info
    # go to Preview Profile and check Header info
    header_stats = @browser.elements(class: 'stats')
    expected_header_stats = "2022 #{@selected_primary_position}  •  #{@selected_height_feet}' #{@selected_height_inches}\" #{@selected_weight}lbs"
    assert_includes header_stats.last.text, expected_header_stats
  end

  def verify_key_stats_header
    header_stats = @browser.elements(class: 'key-type__stats')
    expected_header_stats = "#{@fourty_yard_dash}\n40 Yard Dash\n#{@five_ten_five_Shuttle}\n5-10-5 Shuttle\n#{@Bench_Press}\nBench Press\n#{@Squat}\nSquat"
    assert_includes header_stats.first.text, expected_header_stats
  end
end
