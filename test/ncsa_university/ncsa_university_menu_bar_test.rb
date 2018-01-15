# encoding: utf-8
require_relative '../test_helper'

# TS-201: NCSA University Regression
# UI Test: NCSA University Menu Bar
class NCSAUniversityMenuBarTest < Minitest::Test
  def setup
    _post, post_body = RecruitAPI.new.ppost
    @email = post_body[:recruit][:athlete_email]

    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    UIActions.user_login(@email)
  end

  def teardown
    @browser.close
  end

  def test_ncsa_university_menu_bar
    UIActions.goto_ncsa_university
    menu_bar = @browser.element(:class, 'subheader')
    expect_txt = ['Path to College', 'Recruiting Classes', 
                  'Video Library', 'Resource Library']
    failure = []
    menu_bar.elements(:tag_name, 'a').each do |btn|
      failure << "Found unexpected button #{btn}" unless expect_txt.include? btn.text
      failure << "#{btn} not clickable" unless btn.enabled?
    end

    assert_empty failure
  end
end