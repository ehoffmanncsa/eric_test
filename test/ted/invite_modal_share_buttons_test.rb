# encoding: utf-8
require_relative '../test_helper'

# TED-1408
# UI Test: Share Buttons on the Invite Modal

class InviteModalShareButtonsTest < Common
  def setup
    super
    TED.setup(@browser)
  end

  def teardown
    super
  end

  def check_if_invite_modal_opens
    @browser.button(:class, 'add-btn').click
    UIActions.wait_for_spinner

    assert TED.modal.present?, 'Modal did not open'
    modal_title = 'Invite Athletes'
    assert_equal modal_title,
      TED.modal.element(:id, 'myModalLabel').text,
      "Expected #{modal_title} modal to open"
  end

  def check_copy_button
    copy_input = @browser.element(:class, 'input-group').element(:tag_name, 'input')

    assert_match /https:\/\/team-staging\.ncsasports\.org\/teams\/awesome-sauce\/sign_up/,
      copy_input.attribute('value'),
      'Incorrect Sign Up page URL in Copy link'
  end

  def check_mail_button
    mail_to_link = @browser.element(:class, 'share-buttons').element(:class, 'fa-envelope').parent

    mail_to_text = "mailto:?subject=Start your Awesome Sauce Recruiting Profile"
    assert_includes mail_to_link.attribute('href'), mail_to_text, 'Incorrect URL for mailto link'
  end

  def check_fb_button
    fb_link = @browser.element(:class, 'share-buttons').elements(:tag_name, 'a')[1]

    assert_match /^https:\/\/www\.facebook\.com\/sharer\/sharer\.php\?u=https:\/\/team-staging\.ncsasports\.org\/teams\/awesome-sauce\/sign_up/,
      fb_link.attribute('href'),
      'Incorrect URL for Facebook button'
  end

  def check_twitter_button
    twitter_link = @browser.element(:class, 'share-buttons').elements(:tag_name, 'a')[2]

    assert_match /https:\/\/twitter\.com\/intent\/tweet\?url=https:\/\/team-staging\.ncsasports\.org\/teams\/awesome-sauce\/sign_up/,
      twitter_link.attribute('href'),
      'Incorrect URL for Twitter button'
  end

  def check_go_to_button
    go_to_link = @browser.element(:class, 'share-go-link')
    go_to_link.click
    sleep 1
    @browser.windows.last.use

    assert_equal @browser.element(:tag_name, 'h2').text,
      'AWESOME SAUCE TEAMS UP WITH NCSA TO GIVE YOU A RECRUITING ADVANTAGE',
      'Incorrect title on Sign Up page after clicking go-to link'
  end

  def test_invite_modal_share_buttons
    UIActions.ted_login

    check_if_invite_modal_opens
    check_copy_button
    check_mail_button
    check_fb_button
    check_twitter_button
    check_go_to_button
  end
end
