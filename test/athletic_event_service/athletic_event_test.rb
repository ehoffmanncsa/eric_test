require_relative '../test_helper'

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

class AthleticEventTest < Minitest::Test

  def setup
    @connection_client = AthleticEventServiceClient.new

    @name = MakeRandom.name
    @description = MakeRandom.name
    @event_operator_id = '1'
    @start_date = '2018-12-17 15:27:06'
    @end_date = '2018-12-17 15:27:06'
    @website = MakeRandom.url
    @point_of_contact_name = MakeRandom.name
    @point_of_contact_email = MakeRandom.fake_email
    @registration_link = MakeRandom.url
    @age_range = '12-18'
    @city = MakeRandom.city
    @state = MakeRandom.state
    @logo_url = MakeRandom.url
    @status = 'Draft'
    #@activated_at = '2019-01-08 15:27:06'
    @coach_live_approved = true
  end

  def athletic_event_data
    {
      athletic_event: {
        name: @name,
        description: @description,
        event_operator_id: @event_operator_id,
        start_date: @start_date,
        end_date: @end_date,
        website: @website,
        point_of_contact_name: @point_of_contact_name,
        point_of_contact_email: @point_of_contact_email,
        registration_link: @registration_link,
        age_range: @age_range,
        city: @city,
        state: @state,
        logo_url: @logo_url,
        status: @status,
        #activated_at: @activated_at,
        coach_live_approved: @coach_live_approved,
      }
    }
  end


  def create_athletic_event
    @new_event = @connection_client.post(
      url: "/api/athletic_events/v1/athletic_events",
      json_body: athletic_event_data.to_json
    )
    binding.pry

    refute_empty @new_event, "POST to AES response is empty"

    msg = 'Created data doesnt have same name as POST request'
    assert_equal @new_event['data']['name'],
      athletic_event_data[:athletic_event][:name], msg
  end

  def read_athletic_event
    url = "/api/athletic_events/v1/athetic_events/#{@new_event['data']['id']}"
    expected_data = athletic_event_data[:athletic_event]

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

  def test_create_read_athletic_event
    create_athletic_event
    read_athletic_event
  end
end
