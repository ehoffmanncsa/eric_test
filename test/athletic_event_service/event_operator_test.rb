require_relative '../test_helper'

class EventOperatorTest < Common
  def setup; end

  def teardown; end

  def test_create_event_operator
    connection_client = AthleticEventServiceClient.new

    json_body = {
      event_operator: {
        name: "test",
        primary_email: "primary@primary.com",
        logo_url: "www.logo_url.com",
        website_url: "https://somewebsiteurl.com",
      }
    }.to_json

    response = connection_client.post(
      url: "/api/athletic_events/v1/event_operators",
      json_body: json_body
    )

    assert_equal "test", response["data"]["name"], "Name submitted does not match Name returned"
    assert_equal "primary@primary.com", response["data"]["primary_email"], "Primary_email submitted does not match Primary_email returned"
    assert_equal "www.logo_url.com", response["data"]["logo_url"], "logo_url submitted does not match Logo_url returned"
    assert_equal "https://somewebsiteurl.com", response["data"]["website_url"], "website_url submitted does not match website_url returned"
    assert_instance_of Integer, response["data"]["id"], "Id from response is not an Integer"
  end
end
