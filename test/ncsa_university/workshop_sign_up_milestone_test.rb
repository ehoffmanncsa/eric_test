# encoding: utf-8
require_relative '../test_helper'

# TS-205: NCSA University Regression
# UI Test: Sign Up for Your First Workshop Milestone
class WorkshopSignUpMilestoneTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]

    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    POSSetup.setup(@browser)

    POSSetup.buy_package(@email, 'elite')
    UIActions.user_login(@email)
  end

  def teardown
    @browser.quit
  end

  def test_complete_workshop_signup_milestone
    UIActions.goto_ncsa_university
    milestone = @browser.link(:text, 'Sign up for Rookie Orientation').click

    for i in 1 .. 3
      sticky_wrap = @browser.element(:class, 'sticky-wrap')
      Watir::Wait.while { sticky_wrap.element(:class, 'button--disabled').present? }
      sticky_wrap.element(:class, 'button--wide').click
    end

    list = @browser.element(:class, 'rookie-classes')
    times = list.elements(:class, 'time').to_a
    times.sample.click
    @browser.element(:class, 'button--wide').click; sleep 1

    timeline_history = @browser.element(:class, 'timeline-history')
    milestone = timeline_history.elements(:css, 'li.milestone.point.complete').last
    title = milestone.element(:class, 'title').text
    assert_equal 'Sign Up For Your First Workshop', title, "#{title} - Expected: Sign Up For Your First Workshop"
  end
end
