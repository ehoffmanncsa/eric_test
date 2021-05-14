# encoding: utf-8
require 'gmail'
require 'mail'

class GmailCalls
  attr_accessor :mail_box
  attr_accessor :subject
  attr_accessor :sender

  def initialize; end

  def get_connection
    # login to gmail using email address and app password (not regular password)
    username = Default.static_info['gmail']['username']
    password = Default.static_info['gmail']['app_pass']
    @conn = Gmail.connect(username, password)
  end

  def get_connection_2
    # login to gmail using email address and app password (not regular password)
    username = Default.static_info['gmail_2']['username']
    password = Default.static_info['gmail_2']['app_pass']
    @conn = Gmail.connect(username, password)
  end

  def parse_body(email, keyword = nil)
    if keyword.nil?
      @msg = email.message.to_s
    else
      body = email.multipart? ? email.text_part.decoded : email.body.decoded
      @msg = body.split("\n").detect { |e| e.include? keyword }
    end

    @msg
  end

  def get_unread_emails
    mails = []

    # get unread mails from specific mail box and subject if any
    # keep trying for 300 seconds (5 minutes)
    subject ? (pp "[INFO] Waiting on email #{subject}") : (pp "[INFO] Waiting on email in #{mail_box}")

    five_minutes = 300 # seconds
    begin
      Timeout::timeout(five_minutes) {
        loop do
          mails = @conn.mailbox(mail_box).emails(:unread, :subject => subject)
          break unless mails.empty?
        end
      }
    rescue; end

    mails.empty? ? (pp '[ALERT] No email found...') : (pp '[INFO] Email found!')

    mails
  end

  def delete(emails)
    emails.each { |e| e.read!; e.unread!; e.delete! }
  end

  def remove_unread_emails
    mails = []

    # get unread mails from specific mail box and subject if any
    # clears inbox from other membership scripts
    subject ? (pp "[INFO] Deleting emails #{subject}") : (pp "[INFO] Deleting emails in #{mail_box}")

    seconds = 2
    begin
      Timeout::timeout(seconds) {
        loop do
          mails = @conn.mailbox(mail_box).emails(:unread, :subject => subject)
          break unless mails.empty?
        end
      }
    rescue; end

    mails.empty? ? (pp '[ALERT] No email found...') : (pp '[INFO] Email found!')

    mails
  end

  def send_email(to: nil, from: nil, subject:nil, content:nil)
    @conn.deliver do
      from from
      to to
      subject subject
      text_part do
        body content
      end
    end
  end
end
