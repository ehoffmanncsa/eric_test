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
    @event_operator_data = event_operator_data
    @expected_data = @event_operator_data [:event_operator]
  end

  def sport_ids
    ## preferred using this logic, but only have 5 sports in DB
    ## so comment out for now and use the 5 default ids

    id_set = Default.static_info['sport_ids']
    ids_arr = []

    for i in 1 .. rand(1 .. id_set.length)
      sport_id = id_set.sample
      ids_arr << { ncsa_id: sport_id }
      id_set.delete(sport_id)
    end

    ids_arr
  end

  def logo_urls
    logo_arr = ['https://demoimages-45r6gc2nv.now.sh/zg.png',
    'https://demoimages-45r6gc2nv.now.sh/west_coast_elite.png',
    'https://demoimages-45r6gc2nv.now.sh/chicago_classic_zg.png',
    'https://demoimages-45r6gc2nv.now.sh/battle_for_the_border.png',
    'https://demoimages-45r6gc2nv.now.sh/battle_for_the_belt.png',
    'https://demoimages-45r6gc2nv.now.sh/windy_city_open.png']

    logo_arr.sample
  end

  def event_operator_data
    {
      event_operator: {
        name: MakeRandom.company_name,
        primary_email: MakeRandom.fake_email,
        logo_url: logo_urls,
        website_url: MakeRandom.url,
        sports: sport_ids
      }
    }
  end

  def create_event_operator
    @new_event_operator = @connection_client.post(
      url: "/api/athletic_events/v1/event_operators",
      json_body: @event_operator_data.to_json
    )

    refute_empty @new_event_operator, "POST to 'v1/event_operators' response is empty"

    msg = 'Created data doesnt have same name as POST request'
    assert_equal @new_event_operator['data']['name'],
      @event_operator_data[:event_operator][:name], msg
  end

  def get_creation
    url = "/api/athletic_events/v1/athletic_events/#{@new_event_operator['data']['id']}"
    @connection_client.get(url: url)
  end

  def read_event_operator
    @event = get_creation

    errors_array = []

   @expected_data.each do |key, value|
      next if key == :sports

      msg = "Expected #{key.to_s} #{value}, returned #{@event.dig("data", "#{key}")}."
      errors_array << msg unless @expected_data[:"#{key}"].eql? @event.dig("data", "#{key}")
    end

    if !@event.dig("data", "id").integer?
      errors_array << "Id from response is not an Integer."
    end

    assert_empty errors_array
  end

  def check_sports
    errors_array = []

    expected_sport = @expected_data[:sports]
    event_sport = @event['data']['sports']

    i = 0
    expected_sport.each do |sport|
      id = sport[:ncsa_id]
      actual_id = event_sport[i]['ncsa_id']

      msg = "Expected sport id #{id}, returned #{actual_id}."
      errors_array << msg unless id == actual_id

      i += 1
    end

    errors_array
  end

  def test_create_read_event_operator
    create_event_operator

    read_event_operator
    check_sports
  end
end
