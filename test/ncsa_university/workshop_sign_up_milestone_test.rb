# encoding: utf-8
require_relative '../test_helper'

# TS-205: NCSA University Regression
# UI Test: Sign Up for Your First Workshop Milestone
class WorkshopSignUpMilestoneTest < Minitest::Test
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

  def test_complete_workshop_signup_milestone
    UIActions.goto_ncsa_university
    milestone = @browser.find_element(:link_text, 'Sign up for Rookie Orientation').click

    for i in 1 .. 3
      sticky_wrap = @browser.find_element(:class, 'sticky-wrap')
      sleep 6 if @browser.current_url.include? '/video'
      sticky_wrap.find_element(:class, 'button--wide').click; sleep 2
    end

    list = @browser.find_element(:class, 'rookie-classes')
    times = list.find_elements(:class, 'time')
    times.sample.click; sleep 2
    @browser.find_element(:class, 'button--wide').click

    timeline_history = @browser.find_element(:class, 'timeline-history')
    milestone = timeline_history.find_elements(:css, 'li.milestone.point.complete').last
    title = milestone.find_element(:class, 'title').text
    assert_equal 'Sign Up For Your First Workshop', title, "#{title} - Expected: Sign Up For Your First Workshop"
  end
end
