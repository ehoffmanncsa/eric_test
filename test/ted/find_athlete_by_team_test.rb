# encoding: utf-8
require_relative '../test_helper'

# TED Regression
# UI Test: Find Athlete by Team

=begin
  Coach Admin Tiffany
  In Activity page, apply team filter and make sure
    all returned athletes are in correct team

  PA Otto
  Impersonation Org Awesome Sauce
  In Activity page, apply team filter and make sure
    all returned athletes are in correct team
=end

class FindAthleteByTeamTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    TED.setup(@browser)
  end

  def teardown
    @browser.close
  end

  def select_team
    dropdown = @browser.select_list(:class, 'form-control')
    options = dropdown.options.to_a
    options.each do |option|
      options.delete(option) if (option.text.eql? 'All Teams') || (option.text.eql? '')
    end

    team_name = options.sample.text
    dropdown.select team_name

    team_name
  end

  def check_athletes(team)
    failure = []
    cards = @browser.elements(:class, 'card-content')
    cards.each do |card|
      athlete = card.element(:tag_name, 'h4').text
      details = card.element(:class, 'card-details')
      subtitle = details.element(:class, 'subtitle').text
      failure << "#{athlete} not in team #{team}" unless subtitle.include? team
    end
    assert_empty failure
  end

  def test_coach_admin_find_athletes_by_team
    UIActions.ted_login
    UIActions.wait_for_spinner

    team = select_team
    check_athletes(team)
  end

  def test_PA_find_athletes_by_team
    TED.impersonate_org
    UIActions.wait_for_spinner

    team = select_team
    check_athletes(team)
  end
end
