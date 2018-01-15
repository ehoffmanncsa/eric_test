# encoding: utf-8
require_relative '../test_helper'

# TS-202: NCSA University Regression
# UI Test: Meet Your Team Milestone
class MeetYourTeamMilestoneTest < Minitest::Test
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
    @browser.close
  end

  def test_complete_your_personal_statement_drill
    UIActions.goto_ncsa_university
    milestone = @browser.link(:text, 'Meet my team').click
    @browser.element(:class, 'button--wide').click

    for i in 1 .. 3
      sticky_wrap = @browser.element(:class, 'sticky-wrap')
      Watir::Wait.while { sticky_wrap.element(:class, 'button--disabled').present? }
      sticky_wrap.element(:class, 'button--wide').click
    end

    begin
      Watir::Wait.until { @browser.div(:class, 'mfp-content').visible? }
      popup = @browser.div(:class, 'mfp-content')
      popup.element(:class, 'close-popup').click; sleep 1
    rescue; end

    UIActions.goto_ncsa_university
    timeline_history = @browser.element(:class, 'timeline-history')
    milestone = timeline_history.elements(:css, 'li.milestone.point.complete').last
    title = milestone.element(:class, 'title').text
    assert_equal 'Meet Your Team', title, "#{title} - Expected: Meet Your Team"
  end
end
