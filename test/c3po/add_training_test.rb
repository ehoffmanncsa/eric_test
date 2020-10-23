# encoding: utf-8
require_relative '../test_helper'

# TS-322: C3PO Regression
# UI Test: Training
class AddTrainingTest < Common
  def setup
    super

    C3PO.setup(@browser)

    @training_type = 'this is my training'
    @training_note = 'these are some training notes'
  end

  def teardown
    super
  end

  def training_section
    @browser.element(class: 'athletic_trainings_section')
  end

  def fill_out_form
    # open form
    training_section.element(class: 'add_icon').click
    form = @browser.element(id: 'athletic_training_edit')

    # fill out textboxes
    form.element(name: 'training_type').send_keys @training_type
    form.element(name: 'notes').send_keys @training_note

    # select random year
    dropdown = form.element(name: 'years')
    options = dropdown.elements(tag_name: 'option').to_a
    options.shift; options.sample.click

    # submit form
    form.element(class: 'save').click; sleep 1
  end

  def check_added_training
    boxes = training_section.elements(class: 'box_list')
    refute_empty boxes, 'No box show up after added training'
  end

  def check_profile_history
    # go to Preview Profile
    @browser.element(class: 'button--primary').click; sleep 1

    section =  @browser.element(id: 'about-section')
    training_section = section.element(id: 'training-section')
    row = training_section.elements(tag_name: 'li').to_a.sample

    failure = []
    actual_type = row.element(css: 'div.col.th').text.downcase
    msg = "Expected type: #{@training_type} - Actual type: #{actual_type}"
    failure << msg unless actual_type.eql? @training_type

    actual_note = row.elements(css: 'div.col.td').last.text
    msg = "Expected note: #{@training_note} - Actual note: #{actual_note}"
    failure << msg unless actual_note.eql? @training_note

    assert_empty failure
  end

  def test_add_coach_references
    email = 'testd3c8@yopmail.com'
    UIActions.user_login_2(email)
    sleep 5
    UIActions.goto_edit_profile

    C3PO.goto_athletics

    # add a few trainings
    for i in 1 .. 3
      fill_out_form
    end

    check_added_training
    check_profile_history
  end
end
