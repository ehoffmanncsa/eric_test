# encoding: utf-8
require_relative '../test_helper'

# TS-201: NCSA University Regression
# UI Test: Your Personal Statement Drill
class YourPersonalStatementDrillTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]
    
    @ui = LocalUI.new(true)
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@ui)

    POSSetup.buy_package(@email, 'elite')
    UIActions.user_login(@email)
  end

  def teardown
    @browser.quit
  end

  def test_complete_your_personal_statement_drill
    @browser.find_element(:class, 'recu').click
    drill = @browser.find_elements(:class, 'drill')[2]
    banner = drill.find_element(:class, 'recruiting_u_default').find_element(:class, 'clr').click
    @browser.find_element(:class, 'button--secondary').click

    for i in 1 .. 5
      statement = @browser.find_element(:css, 'div.question.active')
      if i == 5
        statement.find_elements(:class, 'button--wide')[1].click
      else
        statement.find_element(:class, 'button--wide').click
      end
    end

    @browser.find_element(:class, 'button--wide').click
    timeline_history = @browser.find_element(:class, 'timeline-history')
    
    drill_point = timeline_history.find_element(:css, 'li.drill.point.complete')
    title = drill_point.find_element(:class, 'drill-title').text
    assert_equal 'Your Personal Statement', title, "#{title} - Expected: Your Personal Statement"
  end
end
