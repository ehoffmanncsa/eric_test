# encoding: utf-8
require_relative '../test_helper'

# TS-328: C3PO Regression
# UI Test: Additional Sports
class AddAdditionalSportsTest < Common
  def setup
    super

    # This test case is specifically for Football premium
    # Attempt to use a static MVP client
    email = 'ncsa.automation+e6cc@gmail.com'

    C3PO.setup(@browser)
    UIActions.user_login(email, 'ncsa1333')

    @achievements = 'this is my achievements'
  end

  def teardown
    delete_sports
    super
  end

  def delete_sports
    C3PO.goto_athletics
    while sport_box && !sport_box.span(class: 'add_icon').present?
      sport_box.click
      form.button(text: 'Delete').click
      @browser.alert.ok
      sleep 2
    end
  end

  def sport_section
    @browser.element(class: 'additional_sports')
  end

  def sport_box
    sport_section.lis(class: 'box_list').first
  end

  def form
    @browser.div(id: 'additional_sport_edit')
  end

  def open_form
    sport_section.element(class: 'add_icon').click
  end

  def add_sports
    # select items from dropdowns and return value
    open_form
    @sport = get_item('name')
    @years = get_item('years_experience')
    @level = get_item('level')

    # close form
    form.element(class: 'cancel_form').click

    for i in 1 .. 3
      open_form

      # select stuff
      select_item('name', @sport)
      select_item('years_experience', @years)
      select_item('level', @level)

      # fill out textbox
      form.textarea(name: 'achievements').set @achievements

      # submit form
      form.button(value: 'Save Additional Sport').click
      sleep 2
    end
  end

  def get_item(name)
    dropdown = form.element(name: name)
    options = dropdown.options.to_a; options.shift

    options.sample.text
  end

  def select_item(name, value)
    dropdown = form.select_list(name: name)
    dropdown.select(value)
  end

  def check_added_sports
    boxes = sport_section.elements(class: 'box_list').to_a
    refute_empty boxes, 'No box show up after added sports'
  end

  def check_profile_history
    # go to Preview Profile
    @browser.element(class: 'button--primary').click

    section =  @browser.element(id: 'about-section')
    sport_section = section.element(id: 'additional-sports-section')
    row = sport_section.elements(tag_name: 'li').to_a.sample

    failure = []
    actual_name = row.element(css: 'div.col.th').text
    msg = "Expected: #{@sport} - Actual: #{actual_name}"
    failure << msg unless actual_name.eql? @sport

    actual_year = row.elements(css: 'div.col.td').first.text
    msg = "Expected: #{@years} - Actual: #{actual_year}"
    failure << msg unless actual_year.include? @years

    actual_level = row.elements(css: 'div.col.td').last.text
    msg = "Expected: #{@level} - Actual: #{actual_level}"
    failure << msg unless actual_level.eql? @level

    actual_achieve = row.element(class: 'text--size-small').text
    msg = "Expected: #{@achievements} - Actual: #{actual_achieve}"
    failure << msg unless actual_achieve.eql? @achievements

    assert_empty failure
  end

  def test_add_additional_sports
    C3PO.goto_athletics
    add_sports
    check_added_sports
    check_profile_history
  end
end
