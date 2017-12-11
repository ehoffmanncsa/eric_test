# encoding: utf-8
require_relative '../test_helper'

# TS-201: NCSA University Regression
# UI Test: Meet Your Team Milestone
class MeetYourTeamMilestoneTest < Minitest::Test
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
    milestone = @browser.find_element(:link_text, 'Meet my team').click
    @browser.find_element(:class, 'button--wide').click

    for i in 1 .. 3
      sticky_wrap = @browser.find_element(:class, 'sticky-wrap')
      sleep 5 if @browser.current_url.include? '/meet'
      sticky_wrap.find_element(:class, 'button--wide').click
    end

    @browser.find_element(:class, 'recu').click
    timeline_history = @browser.find_element(:class, 'timeline-history')
    milestone = timeline_history.find_elements(:css, 'li.milestone.point.complete').last
    title = milestone.find_element(:class, 'title').text
    assert_equal 'Meet Your Team', title, "#{title} - Expected: Meet Your Team"
  end
end
