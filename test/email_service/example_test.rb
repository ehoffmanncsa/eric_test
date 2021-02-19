# encoding: utf-8
require_relative '../test_helper'
require_relative '../../lib/tools/email_sender'

# TS-38: MS Regression
# UI Test:  How to Add New Recruit to Fasttrack
class ExampleTest < Common
  def test_email_sender
    # We can send an email without any arguments, it will use the defaults found in email_sender.rb
    default_email = EmailSender.send

    # Or, we can manually pass whatever arguments we need
    custom_email = EmailSender.send(
      subject: "This is my custom Subject",
      body: "Hello there, check out my email!"
    )
  end
end
