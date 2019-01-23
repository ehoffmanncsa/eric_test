# encoding: utf-8
require_relative '../test_helper'

# TS-201: NCSA University Regression
# UI Test: Your Personal Statement Drill
class YourPersonalStatementDrillTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]

    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    MSSetup.setup(@browser)

    MSSetup.buy_package(@email, 'elite')
    UIActions.user_login(@email)
  end

  def teardown
    @browser.quit
  end

  def test_complete_your_personal_statement_drill
    UIActions.goto_ncsa_university
    drills = @browser.spans(:class, 'drill-title')
    drills.each do |d|
      d.click if d.text == 'Your Personal Statement'
    end
    @browser.element(:class, 'button--secondary').click

    for i in 1 .. 5
      statement = @browser.element(:css, 'div.question.active')
      if i == 5
        elem = statement.elements(:class, 'button--wide').to_a
        elem[1].click
      else
        statement.element(:class, 'button--wide').click
      end
    end

    @browser.element(:class, 'button--wide').click; sleep 1
    timeline_history = @browser.element(:class, 'timeline-history')

    drill_point = timeline_history.element(:class, 'drill')
    title = drill_point.span(:class, 'drill-title').text
    assert_equal 'Your Personal Statement', title, "#{title} - Expected: Your Personal Statement"
  end
end
