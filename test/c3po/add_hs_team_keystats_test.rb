# encoding: utf-8
require_relative '../test_helper'

# TS-292: C3PO Regression
# UI Test: Add High School Team with Stats, enter an email and run.
class AddHSTeamWithStatsTest < Common
  def setup
    super

    C3PO.setup(@browser)
  end

  def teardown
    super
  end

  def open_hs_team
    teams_section = @browser.element(tag_name: 'high_school_seasons')
    team = teams_section.elements(class: 'box_list').first
    team.click
  end

  # add stats hs team and get back stats headers
  def add_stats_hs_team
    hs_form = @browser.element(id: 'high_school_season_form_container')
    edit_btn = hs_form.element(class: 'edit_stats')
    hs_form.element(class: 'edit_stats').click; sleep 1

    stats_form = @browser.element(id: 'high_school_season_stats_form')
    content_cards = stats_form.elements(class: 'm-content-card')
    stat_headers = []
    content_cards.each do |card|
      stat_headers << card.element(tag_name: 'legend').text.downcase
      card.elements(tag_name: 'input').to_a.sample.send_keys MakeRandom.name
    end

    stats_form.element(class: 'm-button').click
    hs_form.element(class: 'submit').click; sleep 0.5

    stat_headers.join(',')
  end

  def test_add_hs_team_with_stats
    email = 'test2739@yopmail.com'
    UIActions.user_login_2(email)
    sleep 5
    UIActions.goto_edit_profile

    C3PO.goto_athletics
    C3PO.add_hs_team
    open_hs_team
    stat_headers = add_stats_hs_team
    popup_headers = C3PO.get_popup_stats_headers
    assert_includes popup_headers, stat_headers, 'Stats headers not found'
  end
end
