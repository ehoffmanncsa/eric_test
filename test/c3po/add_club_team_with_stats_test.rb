# encoding: utf-8
require_relative '../test_helper'

# TS-311: C3PO Regression
# UI Test: Add Club Teams with STATS
class AddClubTeamWithStatsTest < Common
  def setup
    super

    # This test case is specifically for Football premium
    # Attempt to use a static MVP client
    email = 'ncsa.automation+e6cc@gmail.com'

    C3PO.setup(@browser)
    UIActions.user_login(email, 'ncsa1333')
  end

  def teardown
    delete_stats
    super
  end

  def teams_section
    @browser.element(class: 'club_seasons')
  end

  def first_team
    teams_section.elements(class: 'box_list').first
  end

  def edit_first_team
    first_team.hover
    first_team.link(class: 'edit_link').click
    sleep 2
  end

  # add stats club team and get back stats headers
  def add_stats_club_team
    hs_form = @browser.element(id: 'club_season_form_container')
    edit_btn = hs_form.element(class: 'edit_stats')
    hs_form.element(class: 'edit_stats').click; sleep 0.5

    stats_form = @browser.element(id: 'club_season_stats_form')
    content_cards = stats_form.elements(class: 'm-content-card')
    stat_headers = []
    content_cards.each do |card|
      stat_headers << card.element(tag_name: 'legend').text.downcase
      card.elements(tag_name: 'input').to_a.sample.send_keys MakeRandom.name
    end

    stats_form.element(class: 'm-button').click
    hs_form.element(class: 'submit').click
    sleep 1

    stat_headers.join(',')
  end

  def delete_stats
    # this is only for cleanup
    C3PO.goto_athletics
    edit_first_team
    edit_form = @browser.div(id: 'club_season_edit')
    edit_form.button(text: 'Delete').click; sleep 1
    @browser.alert.ok; sleep 1
  end

  def test_add_club_team_with_stats
    C3PO.goto_athletics
    C3PO.add_club_team
    edit_first_team
    stat_headers = add_stats_club_team
    popup_headers = C3PO.get_popup_stats_headers
    assert_includes popup_headers, stat_headers, 'Stats headers not found'
  end
end
