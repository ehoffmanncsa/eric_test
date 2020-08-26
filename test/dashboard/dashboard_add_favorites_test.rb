# frozen_string_literal: true

require_relative '../test_helper'

# Regression
# UI Test: Verify user can add up to five favorite colleges and have
# those colleges display on the users dashboard
class DashboardAddFavoritesTest < Common
  def setup
    super
    MSSetup.setup(@browser)

    enroll_yr = 'sophomore'
    @clientrms = Default.env_config['clientrms']

    _post, post_body = RecruitAPI.new(enroll_yr).ppost
    @recruit_email = post_body[:recruit][:athlete_email]
    @recruit_name = post_body[:recruit][:athlete_first_name]

    UIActions.user_login(@recruit_email)
    MSSetup.set_password
  end

  def teardown
    super
  end

  def close_supercharge
    supercharge_button = @browser.element(class: 'CloseIcon-lmXKkg')
    supercharge_button.click if supercharge_button.exists?
    sleep 1
    yes_exit_button = @browser.element(text: 'Yes, Exit for Now')
    yes_exit_button.click if yes_exit_button.exists?
    sleep 1
    supercharge_button = @browser.element(class: 'CloseIcon-lmXKkg')
    supercharge_button.click if supercharge_button.exists?
    sleep 2
  end

  def click_add_favorites
    @browser.element('data-test-id': 'add-new-favorite-link').click
    sleep 1
  end

  def click_college_search
    @browser.element(id: 'csm_submit_button_top').click
    sleep 5
  end

  def select_colleges
    i = 0
    rand(2 .. 5).times do |i|
      star = @browser.elements(class: 'favorite').to_a
      star.sample.click
      sleep 2
      i += 1
    end
  end

  def check_favorite_colleges
    #verifiy the text display only found on a favorite college
    failure = []
    failure << "College favorite not found" unless @browser.html.include? 'Next Steps Toward Commitment'
    assert_empty failure
  end

  def clientrms_sign_out
    @browser.element(class: 'fa-angle-down').click
    navbar = @browser.element(id: 'secondary-nav-menu')
    navbar.link(text: 'Logout').click
  end

  def test_dashboard_add_favorites
    close_supercharge
    click_add_favorites
    click_college_search
    select_colleges
    UIActions.goto_dashboard
    sleep 5
    check_favorite_colleges

    clientrms_sign_out
  end
end
