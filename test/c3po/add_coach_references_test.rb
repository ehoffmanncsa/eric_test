# encoding: utf-8
require_relative '../test_helper'

# TS-316: C3PO Regression
# UI Test: Coach References
class AddCoachReferencesTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]
    
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    C3PO.setup(@browser)

    POSSetup.setup(@browser)
    POSSetup.buy_package(@email, 'elite')

    @coach_name = MakeRandom.name
    @coach_email = "#{@coach_name}@fake.com"
  end

  def teardown
    @browser.close
  end

  def coach_section
    @browser.element(:class, 'coach_references_section')
  end

  def fill_out_form
    # open form
    coach_section.element(:class, 'add_icon').click
    form = @browser.element(:id, 'coach_reference_edit')

    # fill out text fields
    form.element(:name, 'name').send_keys @coach_name
    form.element(:name, 'phone_1').send_keys MakeRandom.number(3)
    form.element(:name, 'phone_2').send_keys MakeRandom.number(3)
    form.element(:name, 'phone_3').send_keys MakeRandom.number(4)
    form.element(:name, 'email').send_keys @coach_email

    # select random type
    dropdown = form.select_list(:name, 'coach_type')
    options = dropdown.options.to_a; options.shift
    dropdown.select(options.sample.text)

    # select radio button
    form.elements(:name, 'club_share_activity').first.click

    # submit form
    form.element(:class, 'submit').click; sleep 0.5
  end

  def check_added_coach_ref
    boxes = coach_section.elements(:class, 'box_list')
    refute_empty boxes, 'No box show up after added coach ref'
  end

  def check_profile_history
    # go to Preview Profile
    @browser.element(:class, 'button--primary').click

    about_section = @browser.element(:id, 'about-section')
    coach_ref = about_section.element(:id, 'coach-references-section')
    
    failure = []
    actual_name = coach_ref.element(:css, 'div.col.th').text.downcase
    msg = "Expected name: #{@coach_name} - Actual name: #{actual_name}"
    failure << msg unless actual_name.eql? @coach_name

    actual_email = coach_ref.element(:tag_name, 'a').text
    msg = "Expected email: #{@coach_email} - Actual email: #{actual_email}"
    failure << msg unless actual_email.eql? @coach_email

    assert_empty failure
  end

  def test_add_coach_references
    UIActions.user_login(@email)
    UIActions.goto_edit_profile

    C3PO.goto_athletics
    fill_out_form
    check_added_coach_ref
    check_profile_history
  end
end