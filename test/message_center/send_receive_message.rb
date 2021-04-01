# frozen_string_literal: true

require_relative '../test_helper'

# TS-566: New Message Center Testing
class MessageCenter < Common
  def setup
    super

    # This test case is specifically for Football premium
    # Attempt to use a static MVP client
    # This test sends a message to coach through message center in client-rms and tehn coach replies to the email from personal account.
    email = 'budwilkinson4455@yopmail.com'

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'Inbox'

    C3PO.setup(@browser)
    UIActions.user_login(email, 'ncsa33')
  end

  def compose_message
    @browser.element(class: 'MuiButton-label').click
    college_input = @browser.element(id: 'message-center-college-outbound-selector-input')
    college_input.send_keys 'Purdue University'
    sleep 1
    college_input.click
    @browser.element(id:'message-center-college-outbound-selector-menu', role:'listbox').click

    sleep 3
    coach_input = @browser.element(id: 'message-center-college-coach-selector-input')
    coach_input.send_keys 'Auto'
    @browser.element(id: 'message-center-college-coach-selector-menu').click
    sleep 1
    subject_input = @browser.element(placeholder: 'Subject')
    subject_input.send_keys 'Automated test'
    body_input = @browser.element(class: 'notranslate')
    body_input.send_keys 'Testing message center'
    send_button = @browser.button(class: 'MuiButtonBase-root')
    send_button.click
  end

  def coach
    coach_input = @browser.element(id: 'message-center-college-coach-selector-input')
    coach_input.send_keys 'Automation ncsatest()'
    subject_input = @browser.element(placeholder: 'Subject')
    college_input.send_keys 'Automated test'
   end

  def check_coach_gmail_account
    @gmail.subject = 'Automated test'
    emails = @gmail.get_unread_emails
    failures << 'Could not find automated test email' if emails.empty?
    assert_empty failures
    reply_to_email(emails.first)
  end

  def reply_to_email(email)
    puts email.from, email.to, email.message_id
    from = 'ncsa.automation@gmail.com'
    to = 'bud.wilkinson@test.recruitinginfo.org'
    @gmail.send_email(to: to, from: from, in_reply_to: email.message_id, subject: "Re: #{email.subject}", content: 'Thank you')
  end

  def delete_received_email
    # Deleting email to prevent from populating the inbox
    emails = @gmail.get_unread_emails
    @gmail.delete(emails) unless emails.empty?
  end

  def test_send_receive_message
    C3PO.goto_message_center
    compose_message
    check_coach_gmail_account
    delete_received_email
  end
end
