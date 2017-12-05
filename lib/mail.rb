# encoding: utf-8
require 'gmail'
require 'pp'

class GmailCalls
  attr_accessor :mail_box
  attr_accessor :subject
  attr_accessor :sender

  def initialize; end

  def get_connection
    # login to gmail using email address and app password (not regular password)
    creds = YAML.load_file('config/.creds.yml')
    @conn = Gmail.connect(creds['gmail']['username'], creds['gmail']['app_pass'])
  end

  # get mails from specific mail box and filter
  # keep trying for 15 seconds
  def parse_body(keyword = nil, filter = nil)
    mails = []
    begin
      Timeout::timeout(15) {
        loop do
          mails = @conn.mailbox(mail_box).emails(filter)
          break unless mails.empty?
        end
      }

      # loop through any/all emails which matched our filer
      # get only a part of message that includes desired keyword
      # then delete the email
      mails.each do |email|
        if keyword
          @msg = email.message.to_s.split("\n").select { |e| e.include? keyword }
        else
          @msg = email.message.to_s
        end
        email.delete!
      end
    rescue => e
      puts e
    end

    @msg
  end

  # check if new email is received in a specific mailbox by subject
  def get_emails_by_subject
    mails = []
    Timeout::timeout(60) {
      loop do
        mails = @conn.mailbox(mail_box).emails(:unread, :subject => subject)
        break unless mails.empty?
      end
    }

    mails
  end

  def delete(emails)
    emails.each { |e| e.read!; e.delete! }
  end
end
