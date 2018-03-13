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
    creds = YAML.load_file('config/.creds.yml')
    @conn = Gmail.connect(creds['gmail']['username'], creds['gmail']['app_pass'])
  end

  def parse_body(emails = nil, keyword = nil)
    begin
      # loop through any/all emails
      # get only the part of message that includes the desired keyword
      emails = get_unread_emails if emails.nil?
      emails.each do |email|
        if keyword.nil?
          @msg = email.message.to_s
        else

          @msg = email.message.to_s.split("\n").select { |e| e.include? keyword }
        end
      end
    rescue => e
      puts e
    end

    @msg
  end

  def get_unread_emails
    mails = []

    # get unread mails from specific mail box and subject if any
    # keep trying for 60 seconds
    Timeout::timeout(120) {
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