# encoding: utf-8
require_relative '../../test/test_helper'

class GmailCleaner
  def initialize
    @gmail = GmailCalls.new
    @gmail.get_connection

    @gmail.mail_box = ARGV[0]
  end

  def do_it
    @gmail.delete(@gmail.get_unread_emails)
  end
end

GmailCleaner.new.do_it # remember to pass in mailbox/label as argument
