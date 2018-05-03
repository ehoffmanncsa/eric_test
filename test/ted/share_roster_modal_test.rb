# encoding: utf-8
require_relative '../test_helper'

# TED-1408
# UI Test: Share Buttons on the Invite Modal

class ShareRosterModalTest < Common
  def setup
    super
    TED.setup(@browser)
  end

  def teardown
    super
  end

  def select_sport
    list = @browser.select_list(:class, 'form-control')
    list.select "Women's Basketball"
  end

  def check_if_share_roster_modal_opens
    @browser.button(:text, 'Share Roster').click
    UIActions.wait_for_spinner

    assert TED.modal.present?, 'Modal did not open'
    modal_title = 'Share Roster'
    assert_equal modal_title,
      TED.modal.element(:id, 'myModalLabel').text,
      "Expected #{modal_title} modal to open"
  end

  def check_copy_button
    copy_input = @browser.element(:class, 'input-group').element(:tag_name, 'input')

    assert_equal "https://team-staging.ncsasports.org/teams/womens-basketball/CA/awesome-sauce",
      copy_input.attribute('value'),
      'Incorrect Sign Up page URL in Copy link'
  end

  def check_mail_button
    mail_to_link = @browser.element(:class, 'share-buttons').element(:class, 'fa-envelope').parent

    assert_match /^mailto:\?subject=See%20Awesome%20Sauce/,
      mail_to_link.attribute('href'),
      'Incorrect URL for mailto link'
  end

  def check_fb_button
    fb_link = @browser.element(:class, 'share-buttons').elements(:tag_name, 'a')[1]

    assert_match /^https:\/\/www\.facebook\.com\/sharer\/sharer\.php\?u=https:\/\/team-staging\.ncsasports\.org\/teams\/womens-basketball\/CA\/awesome-sauce/,
      fb_link.attribute('href'),
      'Incorrect URL for Facebook button'
  end

  def check_twitter_button
    twitter_link = @browser.element(:class, 'share-buttons').elements(:tag_name, 'a')[2]

    assert_match /https:\/\/twitter\.com\/intent\/tweet\?url=https:\/\/team-staging\.ncsasports\.org\/teams\/womens-basketball\/CA\/awesome-sauce/,
      twitter_link.attribute('href'),
      'Incorrect URL for Twitter button'
  end

  def check_go_to_button
    go_to_link = @browser.element(:class, 'share-go-link')
    go_to_link.click
    sleep 1
    @browser.windows.last.use

    assert_equal 'Awesome Sauce', @browser.element(:tag_name, 'h2').text, 'Go To page has incorrect header'
    assert_match /Women's Basketball/, @browser.element(:class, 'stats').text, 'Go To page has incorrect sport'
  end

  def employ_share_roster_modal
    TED.go_to_team_tab

    select_sport

    check_if_share_roster_modal_opens
    check_copy_button
    check_mail_button
    check_fb_button
    check_twitter_button
    check_go_to_button
  end

  def test_share_roster_modal_as_coach_admin
    UIActions.ted_login

    employ_share_roster_modal
  end

  def test_share_roster_modal_as_partner_admin
    TED.impersonate_org

    employ_share_roster_modal
  end
end
