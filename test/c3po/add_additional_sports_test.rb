# encoding: utf-8
require_relative '../test_helper'

# TS-328: C3PO Regression
# UI Test: Additional Sports
class AddAdditionalSportsTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]
    
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    C3PO.setup(@browser)

    POSSetup.setup(@ui)
    POSSetup.buy_package(@email, 'elite')

    @achievements = 'this is my achievements'
  end

  def teardown
    @browser.quit
  end

  def sport_section
    @browser.find_element(:class, 'additional_sports')
  end

  def form
    @browser.find_element(:id, 'additional_sport_edit')
  end

  def open_form
    sport_section.location_once_scrolled_into_view
    sport_section.find_element(:class, 'add_icon').click; sleep 0.5
  end

  def add_sports
    # select items from dropdowns and return value
    open_form
    @sport = get_item('name')
    @years = get_item('years_experience')
    @level = get_item('level')

    # close form
    form.find_element(:class, 'cancel_form').click; sleep 0.5

    for i in 1 .. 3
      open_form
      form.location_once_scrolled_into_view

      # select stuff
      select_item('name', @sport)
      select_item('years_experience', @years)
      select_item('level', @level)

      # fill out textbox
      form.find_element(:name, 'achievements').send_keys @achievements

      # submit form
      form.find_element(:class, 'save').click; sleep 0.5
    end
  end

  def get_item(name)
    dropdown = form.find_element(:name, name)
    dropdown.location_once_scrolled_into_view; dropdown.click
    options = dropdown.find_elements(:tag_name, 'option')
    options.shift

    options.sample.text
  end

  def select_item(name, value)
    dropdown = form.find_element(:name, name); dropdown.click
    options = dropdown.find_elements(:tag_name, 'option')
    options.each { |opt| (opt.attribute('value').eql? value) ? opt.click : next }
  end

  def check_added_sports
    boxes = sport_section.find_elements(:class, 'box_list')
    refute_empty boxes, 'No box show up after added sports'
  end

  def check_profile_history
    # go to Preview Profile
    @browser.find_element(:class, 'button--primary').click; sleep 1

    UIActions.wait(40).until { @browser.find_element(:id, 'about-section').displayed? }
    section =  @browser.find_element(:id, 'about-section')
    sport_section = section.find_element(:id, 'additional-sports-section')
    row = sport_section.find_elements(:tag_name, 'li').sample

    failure = []
    actual_name = row.find_element(:css, 'div.col.th').text
    msg = "Expected: #{@sport} - Actual: #{actual_name}"
    failure << msg unless actual_name.eql? @sport

    actual_year = row.find_elements(:css, 'div.col.td').first.text
    msg = "Expected: #{@years} - Actual: #{actual_year}"
    failure << msg unless actual_year.include? @years

    actual_level = row.find_elements(:css, 'div.col.td').last.text
    msg = "Expected: #{@level} - Actual: #{actual_level}"
    failure << msg unless actual_level.eql? @level

    actual_achieve = row.find_element(:class, 'text--size-small').text
    msg = "Expected: #{@achievements} - Actual: #{actual_achieve}"
    failure << msg unless actual_achieve.eql? @achievements

    assert_empty failure
  end

  def test_add_additional_sports
    UIActions.user_login(@email)
    UIActions.goto_edit_profile

    C3PO.goto_athletics
    add_sports
    check_added_sports
    check_profile_history
  end
end
