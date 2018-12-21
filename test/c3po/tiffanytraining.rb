# encoding: utf-8
require_relative '../test_helper'

# TS-201: NCSA University Regression
# UI Test: Welcome to NCSA Drill
class WelcometoNCSATest < Common
  def setup
    super

    C3PO.setup(@browser)
  end

  def teardown
    super
  end

  def test_welcome_to_NCSA_drill
    UIActions.goto_ncsa_university
    drills = @browser.spans(:class, 'drill-title')
    drills.each do |d|
      d.click if d.text == 'Welcome to NCSA U!'
    end
  end

  def get_started
    @browser.button(:class, 'my_button')
    @browser.elements(:class, %w[button--secondary button--wide]).click sleep 1
    @browser.element(:class, 'button--secondary button--wide').click sleep 1
    @browser.element(:class, 'button--secondary button--wide').click
  end

  def click_next
    @browser.element(:class, 'button--wide').click; sleep 1
    timeline_history = @browser.element(:class, 'timeline-history')
    
    drill_point = timeline_history.element(:class, 'drill')
    title = drill_point.span(:class, 'drill-title').text
    assert_equal 'Welcome to NCSA U!', title, "#{title} - Expected: Welcome to NCSA U!"
  end

  def test_do_drill
    email = 'test9a53@yopmail.com'
    UIActions.user_login(email)

    test_welcome_to_NCSA_drill
    get_started
    click_next
  end


  def test_do_drill
    email = 'test9a53@yopmail.com'
    UIActions.user_login(email)

    test_welcome_to_NCSA_drill
    get_started
    click_next
  end


  def test_do_drill
    email = 'test9a53@yopmail.com'
    UIActions.user_login(email)

    test_welcome_to_NCSA_drill
    get_started
    click_next
  end


  def test_do_drill
    email = 'test9a53@yopmail.com'
    UIActions.user_login(email)

    test_welcome_to_NCSA_drill
    get_started
    click_next
  end
end
