# encoding: utf-8
require_relative '../test_helper'

# Ops Messaging Service Regression Test
# SALES-1313: Verify new tracking note created when
#    recruting coach receive email from athlete in HelpScout

class OpsMessagingServiceRegressTest < Common
  def setup
    @gmail = GmailCalls.new
    @gmail.get_connection

    @helpscout_client = HelpScoutClient.new

    @om_config = Default.env_config['ops_messaging']

    super
  end

  def teardown
    super
  end

  def athlete_send_email_to_coach
    @subject = "Ops Messaging Regression #{SecureRandom.hex(2)}"

    sender = @om_config['athlete_email']
    receiver = @om_config['coach_email']
    text = MakeRandom.lorem(rand(3 .. 10))

    @gmail.send_email(subject: @subject, to: receiver, from: sender, content: text)
  end

  def check_help_scout_most_recent_email
    mailbox_id = Default.env_config['helpscout']['coach_ehoffman_mailbox_id']
    query = "conversations?mailbox=#{mailbox_id}&status=open"

    begin
      Timeout::timeout(300) {
        loop do
          _status, response = @helpscout_client.read(query: query)
          email_subject = response['_embedded']['conversations'][0]['subject']
          break if email_subject == @subject
        end
      }
    rescue => error
      raise '[ERROR] not receiving email in helpscout after 5 minute'
    end
  end

  def check_new_tracking_note_created
    athlete_client_id = @om_config['client_id']

    C3PO.setup(@browser)
    UIActions.fasttrack_login
    C3PO.impersonate(athlete_client_id); sleep 1

    failure = []

    begin
      Timeout::timeout(300) {
        loop do
          C3PO.open_tracking_note(athlete_client_id)

          table = @browser.table(:class, %w[l-bln-mg-btm-2 m-tbl tablesorter tn-table])
          latest_note = table.tbody[0].td(:index, 3)
          message_title = latest_note.element(:tag_name, 'h6').text

          break if message_title == @subject
          sleep 2
        end
      }
    rescue => error
      failure << "No new tracking note after 5 minutes - #{error}"
    end

    assert_empty failure
  end

  def test_complete_email_tracking_cycle
    athlete_send_email_to_coach
    check_help_scout_most_recent_email
    check_new_tracking_note_created
  end
end
