# encoding: utf-8
require_relative '../test_helper'

# TS-292: C3PO Regression
# UI Test: Add High School Team with Stats
class AddHSTeamWithStatsTest < Common
  def setup
    super

    # must be a football - premium client
    email = 'ncsa.automation+e6cc@gmail.com'
    UIActions.user_login(email, 'ncsa1333')
    C3PO.setup(@browser)
  end

  def teardown
    delete_hs_team
    super
  end

  def delete_hs_team
    C3PO.goto_athletics
    open_hs_team
    form = @browser.div(id: 'hs_season_edit')
    form.button(text: 'Delete').click
    @browser.alert.ok; sleep 1
  end

  def open_hs_team
    teams_section = @browser.element(class: 'high_school_seasons')
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
      name = card.element(tag_name: 'legend').text.downcase
      next if name.match?(/general/)
      stat_headers << name
      card.elements(tag_name: 'input').to_a.sample.send_keys MakeRandom.name
    end

    stats_form.element(class: 'm-button').click
    hs_form.element(class: 'submit').click; sleep 0.5

    stat_headers.join(',')
  end

  def test_add_hs_team_with_stats
    C3PO.goto_athletics
    C3PO.add_hs_team
    open_hs_team
    stat_headers = add_stats_hs_team
    stat_headers.insert(0, "individual awards,team awards,")
    popup_headers = C3PO.get_popup_stats_headers
    assert_includes popup_headers, stat_headers, 'Stats headers not found'
  end
end
