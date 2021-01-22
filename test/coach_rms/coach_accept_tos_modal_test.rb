# frozen_string_literal: true

require_relative '../test_helper'
# TS-604
# UI Test: "coach have to accept "terms of service" modal either at
# 1. sign up page 2.Viewing Athlete profile or at 3.Search page after login
# once they have accepted at any of the page they will not see the modal again.
# This test covers the third scenario i.e accept TOS at "Search" page after login

class CoachAcceptTosModal < Common
  def coach_rms_login
    @sql = SQLConnection.new('fasttrack')
    begin
      @sql.get_connection
      delete_record = @sql.exec 'DELETE FROM coach_terms_of_service_acceptances where coach_id = 264464'
    rescue StandardError => e
      raise 'Could not connect to fasttrack or delete existing terms of service acceptance records'
    end
    UIActions.coach_rms_login('spt16@yopmail.com')
    sleep 3
end

  def check_modal_is_displayed
    Watir::Wait.until(timeout: 30) { @browser.element(class: 'modal__content').present? }

    tos_modal = @browser.element(class: 'modal__content')
    failures = []
    failures << "modal doesn't display" unless tos_modal.present?
    assert_empty failures
   end

  def accept_terms_of_service
    tos_modal_checkbox = @browser.element(class: 'modal__checkbox', type: 'checkbox')
    tos_modal_checkbox.click
    sleep 1
    continue_button = @browser.element(class: 'modal__button')
    continue_button.click
    UIActions.coach_rms_logout
  end

  def test_modal_present
    coach_rms_login
    check_modal_is_displayed
    accept_terms_of_service
  end
end
