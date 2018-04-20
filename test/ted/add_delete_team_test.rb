# encoding: utf-8
require_relative '../test_helper'

# TS-409: TED Regression
# UI Test: Coach or PA can Add/Delete Team

=begin
  Coach Admin Tiffany
  In Roster Management page, Team tab
  Add team, verify team is added and shows up in UI
  Delete same team, verify team is deleted and not in UI

  PA Otto
  Impersonation Org Awesome Sauce
  In Roster Management page, Team tab
  Add team, verify team is added and shows up in UI
  Delete same team, verify team is deleted and not in UI
=end

class AddDeleteTeamTest < Common
  def setup
    super
    TED.setup(@browser)
  end

  def add_team
    # open modal
    @browser.button(:text, 'Add Team').click
    # add team name
    team_name = MakeRandom.name
    TED.modal.text_field(:class, 'form-control').set team_name
    # select sport
    list = TED.modal.select_list(:class, 'form-control')
    option = list.options.to_a.sample
    list.select option.text
    # submit
    TED.modal.button(:text, 'Add Team').click
    Watir::Wait.while { TED.modal.present? }

    team_name
  end

  def delete_team(team_name)
    team = @browser.element(:text, team_name).parent
    team.element(:class, 'fa-cog').click
    TED.modal.element(:class, 'btn-warning').click; sleep 2
    if TED.modal.present?
      TED.modal.element(:class, 'fa-times').click
    end
  end

  def test_coachadmin_add_delete_team
    UIActions.ted_login
    TED.go_to_team_tab

    new_team = add_team
    assert_includes @browser.html, new_team, 'New team not found'

    delete_team(new_team)
    refute_includes @browser.html, new_team, "Found deleted team #{new_team}"
  end

  def test_PA_add_delete_team
    TED.impersonate_org
    TED.go_to_team_tab

    new_team = add_team
    assert_includes @browser.html, new_team, 'New team not found'

    delete_team(new_team)
    refute_includes @browser.html, new_team, "Found deleted team #{new_team}"
  end
end
