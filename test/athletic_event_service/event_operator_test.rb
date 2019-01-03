require_relative '../test_helper'

class EventOperatorTest < Common
  def setup; end

  def teardown; end

  def test_create_event_operator
    connection_client = AthleticEventServiceClient.new

    event_operator_data = {
      name: MakeRandom.company_name,
      primary_email: MakeRandom.fake_email,
      logo_url: MakeRandom.url,
      website_url: MakeRandom.url,
    }

    json_body = {
      event_operator: event_operator_data
    }.to_json

    response = connection_client.post(
      url: "/api/athletic_events/v1/event_operators",
      json_body: json_body
    )

    errors_array = []

    if event_operator_data[:name] != response["data"]["name"]
      errors_array <<  "Name submitted does not match Name returned"
    end

    if event_operator_data[:primary_email] != response["data"]["primary_email"]
      errors_array << "Primary_email submitted does not match Primary_email returned"
    end

    if event_operator_data[:logo_url] != response["data"]["logo_url"]
      errors_array << "Logo_url submitted does not match logo_url returned"
    end

    if event_operator_data[:website_url] != response["data"]["website_url"]
      errors_array << "Website_url submitted does not match website_url returned"
    end

    if !response["data"]["id"].integer?
      errors_array << "Id from response is not an Integer"
    end

    assert_empty errors_array
  end
end
