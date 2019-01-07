require_relative '../test_helper'

class EventOperatorTest < Common
  def setup
    @connection_client = AthleticEventServiceClient.new

    @event_operator_data = { event_operator:
      {
        name: MakeRandom.company_name,
        primary_email: MakeRandom.fake_email,
        logo_url: MakeRandom.url,
        website_url: MakeRandom.url,
      }
    }.to_json
  end

  def teardown; end

  def create_event_operator
    response = connection_client.post(
      url: "/api/athletic_events/v1/event_operators",
      json_body: @event_operator_data
    )

    errors_array = []

    if response.empty?
      errors_array << "Empty response."
    end

    if response["data"].empty?
      errors_array <<  "Empty data."
    end

    assert_empty errors_array
  end

  def read_event_operator
    if event_operator_data[:name] != response.dig("data", "name")
      errors_array <<  "name mismatch: submitted #{event_operator_data[:name]}, returned #{response.dig("data", "name")}."
    end

    if event_operator_data[:primary_email] != response.dig("data", "primary_email")
      errors_array << "primary_email mismatch: submitted #{event_operator_data[:primary_email]}, returned #{response.dig("data", "primary_email")}."
    end

    if event_operator_data[:logo_url] != response.dig("data", "logo_url")
      errors_array << "logo_url mismatch: submitted #{event_operator_data[:logo_url]}, returned #{response.dig("data", "logo_url")}."
    end

    if event_operator_data[:website_url] != response.dig("data", "website_url")
      errors_array << "website_url mismatch: submitted #{event_operator_data[:website_url]}, returned #{response.dig("data", "website_url")}."
    end

    if !response.dig("data", "id").integer?
      errors_array << "Id from response is not an Integer."
    end
  end

  def test_create_read_event_operator
    create_event_operator
  end
end

=begin
//call this later when i figure out the syntax for GET in AES
//read_event_operator
Sample Expected Response
{
  "data"=> {
    "website_url "=>" http://pfeffer.se",
     "primary_email "=>" jillian_stehr@parker.com",
     "name "=>" Schaden Inc",
     "logo_url "=>" http://morar.se",
     "id"=>39
    }
}
=end
