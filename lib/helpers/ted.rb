# encoding: utf-8
require_relative '../../test/test_helper'

# This helper is to help in performing TED related actions
module TED
  def self.setup(ui_object)
    @browser = ui_object
    UIActions.setup(@browser)
  end

  def self.go_to_athlete_tab
    # go to administration -> athlete
    Watir::Wait.until { @browser.element(:class, 'sidebar').visible? }
    @browser.link(:text, 'Administration').click
    Watir::Wait.until { @browser.element(:id, 'react-tabs-1').present? }
    @browser.element(:id, 'react-tabs-2').click; sleep 3
    Watir::Wait.until { @browser.element(:id, 'react-tabs-3').visible? }
  end

  def self.go_to_staff_tab
    # go to administration -> staff
    Watir::Wait.until { @browser.element(:class, 'sidebar').visible? }
    @browser.link(:text, 'Administration').click
    Watir::Wait.until { @browser.element(:id, 'react-tabs-1').visible? }
    @browser.element(:id, 'react-tabs-4').click; sleep 3
    Watir::Wait.until { @browser.element(:id, 'react-tabs-5').visible? }
  end

  def self.sign_out
    sidebar = @browser.element(:class, 'sidebar')
    sidebar.element(:class, 'signout').click; sleep 1
  end

  def self.get_row_by_name(table, name)
    rows = table.elements(:tag_name, 'tr').to_a; rows.shift
    rows.detect { |r| r.elements(:tag_name, 'td')[0].text.eql? name }
  end

  def self.get_athlete_status(table, name = nil)
    go_to_athlete_tab
    row = get_row_by_name(table, name)

    row.elements(:tag_name, 'td')[4].text # this is status
  end

  def self.delete_athlete(table, name)
    row = TED.get_row_by_name(table, name)
    cog = row.elements(:tag_name, 'td').last.element(:class, 'fa-cog')
    cog.click; sleep 1
    modal = @browser.div(:class, 'modal-content')
    modal.button(:text, 'Delete').click
    small_modal = modal.div(:class, 'modal-content')
    small_modal.button(:text, 'Delete').click; sleep 1
  end
end
