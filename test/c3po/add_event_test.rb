# encoding: utf-8
require_relative '../test_helper'

# TS-289: C3PO Regression
# UI Test: Add event
class AddEventTest < Common
  def setup
    super

    C3PO.setup(@browser)
  end

  def teardown
    super
  end

  def add_event
    # open event form
    event_section = @browser.element(class: 'athletic_events_section')
    event_section.element(class: 'f-yes add_elem add-element-side').click


    dropdown = @browser.element(class: 'text category')
    options = dropdown.elements(tag_name: 'option').to_a

    options.each do |option|
      option.click if option.text == 'Camp'
    end
    # fill out textboxes
    form = @browser.element(id: 'athletic_event_edit')

    form.element(name: 'name').send_keys "Event Name"
    form.element(name: 'location').send_keys "Event Location"
    form.element(name: 'city').send_keys "Event City"

    dropdown = @browser.element(class: 'text state')
    options = dropdown.elements(tag_name: 'option').to_a

    options.each do |option|
      option.click if option.text == 'IL'
    end

    form.element(name: 'start_date').send_keys "09/05/2018"
    form.element(name: 'end_date').send_keys "09/06/2018"
    form.element(name: 'notes').send_keys "I am some Event Notes"
    form.element(class: 'save').click;
  end

  def verify_event
    # go to Preview Profile and check event
    @browser.element(class: 'button--primary').click;
    event = @browser.elements(class: 'info-category events')
    expected_event = "EVENTS\nPast Events\nEVENT NAME\nSep 05, 2018 - Sep 06, 2018\nEvent Location, Event City, IL"+
    "\nI am some Event Notes"
    assert_includes event.first.text, expected_event
  end

  def test_add_event
    email = 'test431f@yopmail.com'
    UIActions.user_login_2(email)
    sleep 5
    UIActions.goto_edit_profile

    C3PO.goto_events

    add_event
    verify_event
  end
end
