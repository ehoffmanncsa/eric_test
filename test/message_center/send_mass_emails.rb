# encoding: utf-8
require_relative '../test_helper'

# This test will automate sending email with same subject to 20 or more people
# and mapping their email_type in database, email type of mass emails = 1000 as per the new update
#https://ncsasports.atlassian.net/browse/PREM-4857

class SendMassEmails < Common
  def setup
    super

    # This test sends a mass emails from football coach personal gmail account.

        @gmail = GmailCalls.new
        @gmail.get_connection_2
        @gmail.mail_box = 'Inbox'
   end

    def send_mass_emails
        emails_to_test = ['mikedanny.tester@test.recruitinginfo.org','versie.nader@test.recruitinginfo.org','marty.smith@test.recruitinginfo.org','evelin.king@test.recruitinginfo.org','kesin.louis@test.recruitinginfo.org','paulina.vega@test.recruitinginfo.org',
        'sheryl.vega@test.recruitinginfo.org','sprint.regression2@test.recruitinginfo.org','hello.ncsa@test.recruitinginfo.org','alberto.neives@test.recruitinginfo.org','sprint.ncsa6@test.recruitinginfo.org','apriltesting.ncsa@test.recruitinginfo.org','david.peterson@test.recruitinginfo.org',
        'delpha.grady@test.recruitinginfo.org','gretta.ruecker@test.recruitinginfo.org','melynda.schneider@test.recruitinginfo.org','lisette.brakus@test.recruitinginfo.org','akshil.wilkinson@test.recruitinginfo.org','dhruvin.johnson@test.recruitinginfo.org','<erica.vega@test.recruitinginfo.org>','joshua.johnson7@test.recruitinginfo.org','jones.hall@test.recruitinginfo.org']
        send_email_hash = {to: emails_to_test, from: 'hsaraiyancsa@gmail.com', subject: 'Automated_mass_emails', content: 'These are mass emails'}
        @gmail.get_connection_2
        @gmail.send_email(send_email_hash)
        sleep 2
    end

    def delete_old_messages
        @psql  = PostgresConnection.new('message_center')
        @psql.get_connection
        delete_old_messages = @psql.exec "DELETE FROM messages WHERE subject ='Automated_mass_emails'"
    end

  def check_messages
      @psql  = PostgresConnection.new('message_center')
    begin
      @psql.get_connection
      check_record = @psql.exec "SELECT * FROM messages WHERE subject ='Automated_mass_emails' ORDER BY created_at DESC"
    rescue StandardError => e
      raise "Could not connect to message center or find email wth subject 'Automated_mass_emails'"
    end
  end

  def retrive_email_type
    data = @psql.exec "SELECT * FROM messages WHERE subject = 'Automated_mass_emails'"
    client_ids = []
    data.each do|row|
      email_types = row['email_type']
      map_email_type = email_types
      print map_email_type
  end
end


def retrive_client_ids
   data = @psql.exec "SELECT * FROM messages WHERE subject = 'Automated_mass_emails'"
   client_ids = []
   data.each do|row|
     client_ids = row['client_id']
     mass_email_client_ids = client_ids
     print mass_email_client_ids
    end
end

    def test_send_mass_emails
         delete_old_messages
         send_mass_emails
         check_messages
         sleep 8
        retrive_email_type
        retrive_client_ids
    end
end
