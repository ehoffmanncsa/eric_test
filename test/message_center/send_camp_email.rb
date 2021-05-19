# encoding: utf-8
require_relative '../test_helper'

# This test will automate sending email single camp email
# and mapping their email_type in database, email type of camp email = 1002

class SendCampEmail < Common
  def setup
    super

    # This test sends a camp email from football coach personal gmail account.

    @gmail = GmailCalls.new
    @gmail.get_connection_2
    @gmail.mail_box = 'Inbox'
   end

  def send_camp_email
    emails_to_test = ['paulina.vega@test.recruitinginfo.org']
    send_email_hash = { to: emails_to_test, from: 'hsaraiyancsa@gmail.com', subject: 'Automated_camp_email', content: 'Showcase and combine' }
    @gmail.get_connection_2
    @gmail.send_email(send_email_hash)
    sleep 2
  end

  def delete_old_messages
    @psql = PostgresConnection.new('message_center')
    @psql.get_connection
    delete_old_messages = @psql.exec "DELETE FROM messages WHERE subject ='Automated_camp_email'"
  end

  def check_messages
    @psql = PostgresConnection.new('message_center')
    begin
      @psql.get_connection
      check_record = @psql.exec "SELECT * FROM messages WHERE subject ='Automated_camp_email' ORDER BY created_at DESC"
    rescue StandardError => e
      raise "Could not connect to message center or find email wth subject 'Automated_camp_email'"
    end
 end

  def retrive_email_type
    data = @psql.exec "SELECT * FROM messages WHERE subject = 'Automated_camp_email'"
    client_ids = []
    data.each do |row|
      email_types = row['email_type']
      map_email_type = email_types
      print map_email_type
    end
end

  def test_send_camp_email
    delete_old_messages
    send_camp_email
    check_messages
    retrive_email_type
  end
end
