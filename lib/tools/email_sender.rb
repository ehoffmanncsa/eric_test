require "json"
require_relative "email_service"

BASE_URL = "/api/email_service/emails".freeze

# EmailSender allows you to easiy send emails through email service.
# It provides most of the default arguments that you need, but you can override them.
#
# Example:
# ```ruby
# require_relative "../lib/tools/email_sender"
#
# EmailSender.send(
#   subject: "This is the subject",
#   body: "This is the body"
# )
# ````

class EmailSender
  def self.send(
    recipients: ["hsaraiyancsa@gmail.com"],
    sender: "noreply@ncsasports.org",
    subject: "Default subject",
    body: "Default body",
    priority: "low",
    categories: ["client_to_coach"]
  )
    conn = EmailService::ApiClient::Connection.new
    conn.post(BASE_URL, {
      "email" => {
        "recipients" => {
          "to" => recipients
        },
        "sender" => sender,
        "body" => body,
        "priority" => priority,
        "subject" => subject,
        "categories" => categories,
        "metadata" => {},
        "headers" => {
          "X-Mailer" => "EmailService"
        },
      }
    }.to_json)
  end
end
