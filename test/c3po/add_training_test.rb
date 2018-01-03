# encoding: utf-8
require_relative '../test_helper'

# TS-322: C3PO Regression
# UI Test: Training
class AddTrainingTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]
    
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    C3PO.setup(@browser)

    POSSetup.setup(@ui)
    POSSetup.buy_package(@email, 'elite')

    @training_type = 'this is my training'
    @training_note = 'these are some training notes'
  end

  def teardown
    @browser.quit
  end

  def training_section
    @browser.find_element(:class, 'athletic_trainings_section')
  end

  def fill_out_form
    # open form
    training_section.find_element(:class, 'add_icon').click; sleep 0.5
    form = @browser.find_element(:id, 'athletic_training_edit')

    # fill out textboxes
    form.find_element(:name, 'training_type').send_keys @training_type
    form.find_element(:name, 'notes').send_keys @training_note

    # select random year
    dropdown = form.find_element(:name, 'years')
    options = dropdown.find_elements(:tag_name, 'option')
    options.shift; options.sample.click

    # submit form
    form.find_element(:class, 'save').click; sleep 1
  end

  def check_added_training
    boxes = training_section.find_elements(:class, 'box_list')
    refute_empty boxes, 'No box show up after added training'
  end

  def check_profile_history
    # go to Preview Profile
    @browser.find_element(:class, 'button--primary').click; sleep 1

    UIActions.wait(40).until { @browser.find_element(:id, 'about-section').displayed? }
    section =  @browser.find_element(:id, 'about-section')
    training_section = section.find_element(:id, 'training-section')
    row = training_section.find_elements(:tag_name, 'li').sample

    failure = []
    actual_type = row.find_element(:css, 'div.col.th').text.downcase
    msg = "Expected type: #{@training_type} - Actual type: #{actual_type}"
    failure << msg unless actual_type.eql? @training_type

    actual_note = row.find_elements(:css, 'div.col.td').last.text
    msg = "Expected note: #{@training_note} - Actual note: #{actual_note}"
    failure << msg unless actual_note.eql? @training_note

    assert_empty failure
  end

  def test_add_coach_references
    UIActions.user_login(@email)
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
