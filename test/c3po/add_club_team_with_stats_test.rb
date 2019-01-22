# encoding: utf-8
require_relative '../test_helper'

# TS-311: C3PO Regression
# UI Test: Add Club Teams with STATS
class AddClubTeamWithStatsTest < Common
  def setup
    super

    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]

    C3PO.setup(@browser)
    MSSetup.setup(@browser)

    MSSetup.buy_package(@email, 'elite')
  end

  def teardown
    super
  end

  def open_club_team
    teams_section = @browser.element(:class, 'club_seasons')
    team = teams_section.elements(:class, 'box_list').first
    team.click
  end

  # add stats club team and get back stats headers
  def add_stats_club_team
    hs_form = @browser.element(:id, 'club_season_form_container')
    edit_btn = hs_form.element(:class, 'edit_stats')
    hs_form.element(:class, 'edit_stats').click; sleep 0.5

    stats_form = @browser.element(:id, 'club_season_stats_form')
    content_cards = stats_form.elements(:class, 'm-content-card')
    stat_headers = []
    content_cards.each do |card|
      stat_headers << card.element(:tag_name, 'legend').text.downcase
      card.elements(:tag_name, 'input').to_a.sample.send_keys MakeRandom.name
    end

    stats_form.element(:class, 'm-button').click
    hs_form.element(:class, 'submit').click

    stat_headers.join(',')
  end

  def test_add_club_team_with_stats
    UIActions.user_login(@email)
    UIActions.goto_edit_profile

    C3PO.goto_athletics
    C3PO.add_club_team
    open_club_team
    stat_headers = add_stats_club_team
    popup_headers = C3PO.get_popup_stats_headers
    assert_includes popup_headers, stat_headers, 'Stats headers not found'
  end
end
