require_relative '../test_helper'


# CLIVE-19, CLIVE-20,
=begin
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

class EventOperatorTest < Minitest::Test

  def setup
    @connection_client = AthleticEventServiceClient.new

    @company_name = MakeRandom.company_name
    @email = MakeRandom.fake_email
    @logo_url = MakeRandom.url
    @website_url = MakeRandom.url
  end

  def sport_ids
    ## preferred using this logic, but only have 5 sports in DB
    ## so comment out for now and use the 5 default ids
    # id_set = Default.static_info['sport_ids']

    id_set = [17634, 17638, 17683, 17684, 17639]
    ids_arr = []

    for i in 1 .. rand(1 .. id_set.length)
      sport_id = id_set.sample
      ids_arr << { ncsa_id: sport_id }
      id_set.delete(sport_id)
    end

    ids_arr
  end

  def event_operator_data
    {
      event_operator: {
        name: @company_name,
        primary_email: @email,
        logo_url: @logo_url,
        website_url: @website_url,
        sports: sport_ids
      }
    }
  end

  def create_event_operator
    @new_event = @connection_client.post(
      url: "/api/athletic_events/v1/event_operators",
      json_body: event_operator_data.to_json
    )

    refute_empty @new_event, "POST to 'v1/event_operators' response is empty"

    msg = 'Created data doesnt have same name as POST request'
    assert_equal @new_event['data']['name'],
      event_operator_data[:event_operator][:name], msg
  end

  def read_event_operator
    url = "/api/athletic_events/v1/event_operators/#{@new_event['data']['id']}"
    expected_data = event_operator_data[:event_operator]

    event = @connection_client.get(url: url)

    errors_array = []

    expected_data.each do |key, value|
      msg = "Expected #{key.to_s} #{value}, returned #{event.dig("data", "#{key}")}."
      errors_array << msg unless expected_data[:"#{key}"].eql? event.dig("data", "#{key}")
    end

    if !event.dig("data", "id").integer?
      errors_array << "Id from response is not an Integer."
    end

    assert_empty errors_array
  end

  def test_create_read_event_operator
    create_event_operator
    read_event_operator
  end
end
