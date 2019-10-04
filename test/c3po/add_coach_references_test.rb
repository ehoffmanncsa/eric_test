# encoding: utf-8
require_relative '../test_helper'

# TS-316: C3PO Regression
# UI Test: Coach References
class AddCoachReferencesTest < Common
  def setup
    super
    email = 'ncsa.automation+e6cc@gmail.com'
    UIActions.user_login(email, 'ncsa1333')
    C3PO.setup(@browser)
    @coach_name = MakeRandom.name
    @coach_email = "#{@coach_name}@fake.com"
  end

  def teardown
    delete_coach_ref
    super
  end

  def coach_section
    @browser.element(class: 'coach_references_section')
  end

  def form
    @browser.element(id: 'coach_reference_edit')
  end


  def fill_out_form
    # open form
    coach_section.element(class: 'add_icon').click

    # fill out text fields
    form.element(name: 'name').send_keys @coach_name
    form.element(name: 'phone').send_keys MakeRandom.number(10)
    form.element(name: 'email').send_keys @coach_email

    # select random type
    dropdown = form.select_list(name: 'coach_type')
    options = dropdown.options.to_a; options.shift
    dropdown.select(options.sample.text)

    # select radio button
    form.elements(name: 'club_share_activity').first.click

    # submit form
    form.element(class: 'submit').click; sleep 0.5
  end

  def check_added_coach_ref
    boxes = coach_section.elements(class: 'box_list')
    refute_empty boxes, 'No box show up after added coach ref'
  end

  def check_profile_history
    #go to Preview Profile
    @browser.element(class: 'button--primary').click

    about_section = @browser.element(id: 'about-section')
    coach_ref = about_section.element(id: 'coach-references-section')

    failure = []
    actual_name = coach_ref.element(css: 'div.col.th').text.downcase
    msg = "Expected name: #{@coach_name} - Actual name: #{actual_name}"
    failure << msg unless actual_name.eql? @coach_name

    actual_email = coach_ref.element(tag_name: 'a').text
    msg = "Expected email: #{@coach_email} - Actual email: #{actual_email}"
    failure << msg unless actual_email.eql? @coach_email

    assert_empty failure
  end

  def coach_ref_wrapper
    @browser.ol(id: 'coach_references_list')
  end

  def delete_coach_ref
    C3PO.goto_athletics
    coach_ref_wrapper.scroll.to :center; sleep 2
    coach_ref = coach_ref_wrapper.li(class: %w[box_list sc-purp])
    coach_ref.hover; sleep 2
    coach_ref.link(class: 'edit_link').click; sleep 2
    coach_ref_wrapper.button(text: 'Delete').click; sleep 1
    @browser.alert.ok; sleep 1
  end

  def test_add_coach_references
    C3PO.goto_athletics
    fill_out_form
    check_added_coach_ref
    check_profile_history
  end
end
