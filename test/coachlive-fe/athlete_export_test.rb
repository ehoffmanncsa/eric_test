# frozen_string_literal: true

require_relative '../test_helper'

# This test will export tracked athletes in a csv to the
#  ncsa.automation@gmail.com CoachLive inbox.
#  We are unable to open the csv in the email at this time

class CoachLiveExportTest < Common
  def setup
    super
    @gmail = GmailCalls.new
    @gmail.get_connection

    AthleticEventUI.setup(@browser)
  end

  def click_menu
    @browser.element('data-icon': 'bars').click
    sleep 3
  end

  def open_athlete
    @browser.element(xpath: "//a[@href='/athletes/tracked']").click
    sleep 5
  end

  def select_athletes
    i = 0
    rand(2 .. 7).times do |i|
      checkbox = @browser.elements('data-icon': 'square').to_a
      checkbox.sample.click
      sleep 2
      i += 1
    end
  end

  def click_ellipsis
    @browser.element('data-icon': 'ellipsis-h').click
    sleep 3
  end

  def select_export
    @browser.element(role: 'menuitem').click
    sleep 3
  end

  def click_ok
    ok = @browser.button(text: 'OK')
    ok.click
  end

  def close_app
    @browser.button(text: 'Log out').click
  end

  def log_into_Coach_Packet
    AthleticEventUI.adjust_window
    AthleticEventUI.login_with_password
  end

  def test_athlete_export
    log_into_Coach_Packet
    click_menu
    open_athlete
    select_athletes
    click_ellipsis
    select_export
    AthleticEventUI.get_login_url
    AthleticEventUI.delete_email
    click_menu
    close_app
  end
end
