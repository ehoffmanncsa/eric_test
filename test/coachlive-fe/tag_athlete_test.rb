# frozen_string_literal: true

require_relative '../test_helper'

require 'time'
require 'date'

# UI Test: Tag athlete and verify athlete displays on Tracked Athlete page
class AddAthleteTagTest < Common
  def setup
    super
    AthleticEventUI.setup(@browser)
    AthleticEventUI.adjust_window
    AthleticEventUI.login_with_password

  end

  def search_for_event
    search = @browser.element("data-automation-id": 'SearchBox')
    search.scroll.to
    @browser.text_field(type: 'text').send_keys 'Gutmann Group'
    sleep 2
  end

  def open_event
    open_event = @browser.element(text: 'Gutmann Group')
    open_event.click
    sleep 2
  end

  def select_tag_color
    @browser.element('data-icon': 'tag').click
    sleep 2
    @tag = AthleticEventUI.tag
    tag_color = @browser.elements("data-automation-id": @tag.to_s).to_a
    tag_color.sample.click
    sleep 2
  end

  def athlete_name_profile
    # gets the athlete name on the athlete profile page
    @display_athlete_name = @browser.element("data-automation-id": 'EventName').text
  end

  def search_athlete
    # verify that the athlete with the tag displays on Tracked Athlete page
    failure = []
    failure << "Athlete #{@display_athlete_name} not found" unless @browser.html.include? @display_athlete_name
    assert_empty failure
  end

  def untag_athlete
    @browser.element('data-icon': 'tag').click
    sleep 2
    @browser.element('data-automation-id': 'tag0').click
    sleep 2
  end

  def test_tag_added_tracked_athlete
    AthleticEventUI.display_past_events
    search_for_event
    open_event
    sleep 1
    AthleticEventUI.open_athlete_profile
    select_tag_color
    athlete_name_profile
    AthleticEventUI.select_hamburger_menu
    AthleticEventUI.select_tracked_athlete_page
    search_athlete
    AthleticEventUI.open_athlete_profile
    untag_athlete
  end
end
