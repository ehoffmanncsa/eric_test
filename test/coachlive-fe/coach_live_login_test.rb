# encoding: utf-8
require_relative '../test_helper'

# Eric to add JIRA ticket number if any

class CoachLiveLoginTest < Common
  def setup
    @gmail = GmailCalls.new
    @gmail.get_connection

    super

    # adjust browser size
    width = 411 # I think this is pixel?
    height = 650
    @browser.window.resize_to(width, height)
  end

  def teardown
    super
  end

  def request_login
    @browser.goto 'http://coachlive-staging.ncsasports.org/login'
    sleep 3

    email = @browser.text_field(:name, 'email')
    email.set 'ncsa.automation+coachlive@gmail.com'

    submit_button = @browser.button(:text, 'Email me a login link')
    submit_button.click
    sleep 3
  end

  def get_new_coachlive_email
    @gmail.mail_box = 'CoachLive'
    @gmail.get_unread_emails.last
  end

  def get_login_url
    email = get_new_coachlive_email

    keyword = 'sendgrid.net/wf/click?'
    msg = @gmail.parse_body(email, keyword).strip!
    msg = "https" + msg.split('https')[1]

    msg
  end

  def test_login
    request_login

    login_url = get_login_url
    @browser.goto login_url

    sleep 20
  end
end
