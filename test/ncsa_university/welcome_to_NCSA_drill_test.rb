# encoding: utf-8
require_relative '../test_helper'

# TS-201: NCSA University Regression
# UI Test: Welcome to NCSA Drill is for premium members only.
class WelcometoNCSATest < Common
  def setup
    super

    C3PO.setup(@browser)
  end

  def teardown
    super
  end

  def get_started
    loop do
      next_buttons = @browser.elements(:class, %w[button--wide])

      next_buttons.each do |button|
        next unless button.visible?
        button.click
        break
      end

      sleep 1
      break if @browser.html.include? 'Your Path To College'
    end
  end

  def verify_drill_completed

    timeline_history = @browser.element(:class, 'timeline-history')
    
    drill_point = timeline_history.element(:class, 'drill')
    title = drill_point.span(:class, 'drill-title').text
    assert_equal 'Welcome to NCSA U!', title, "#{title} - Expected: Welcome to NCSA U!"
  end

  def test_do_drill
  
    email = 'test6170@yopmail.com'
    UIActions.user_login(email)

    UIActions.goto_ncsa_university

    drills = @browser.spans(:class, 'drill-title')
    drills.each do |d|
      d.click if d.text == 'Welcome to NCSA U!'
      break
    end

    get_started
    verify_drill_completed
  end
end
