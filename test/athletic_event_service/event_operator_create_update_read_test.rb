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

class EventOperatorCRUTest < Minitest::Test
  def setup
    @connection_client = AthleticEventServiceClient.new
  end

  def sport_ids
    id_set = Default.static_info['sport_ids']

    ids_arr = []

    for i in 1 .. rand(1 .. 4)
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
        partner_event_id: 14086,
        sports: sport_ids
      }
    }
  end

  def create_event_operator
    @new_event_operator = begin
                            retries ||= 0
                            @connection_client.post(
                              url: '/api/athletic_events/v1/event_operators',
                              json_body: @original_data.to_json)
                          rescue => e
                            msg = "#{e} \nPOST body \n#{@original_data} \nGoing to retry"
                            puts msg; sleep 2
                            retry if (retries += 1) < 2
                          end
  end

  def check_creation(new_event_operator)
    refute_empty @new_event_operator, "POST to 'v1/event_operators' response is empty"

    msg = 'Created data doesnt have same name as POST request'
    assert_equal @new_event_operator['data']['name'],
      @original_data[:event_operator][:name], msg
  end

  def get_my_event_operator
    url = "/api/athletic_events/v1/event_operators/#{@new_event_operator['data']['id']}"
    @connection_client.get(url: url)
  end

  def update_event_operator(new_data)
    endpoint = "/api/athletic_events/v1/event_operators/#{@new_event_operator['data']['id']}"

    begin
      retries ||= 0
      @connection_client.put(
        url: endpoint,
        json_body: new_data.to_json)
    rescue => e
      msg = "#{e} \nPUT body \n#{new_data} \nGoing to retry"
      puts msg; sleep 2
      retry if (retries += 1) < 2
    end
  end

  def read_event_operator(expected_data, data_from_api)
    errors_array = []

    expected_data = expected_data[:event_operator]
    expected_data.each do |key, value|
      next if key == :sports

      msg = "Expected #{key.to_s} #{value}, returned #{data_from_api.dig("data", "#{key}")}."
      errors_array << msg unless expected_data[:"#{key}"].eql? data_from_api.dig("data", "#{key}")
    end

    check_sports_result = check_sports(expected_data, data_from_api)
    errors_array << check_sports_result unless check_sports_result.empty?
    errors_array.flatten!

    if !data_from_api.dig("data", "id").integer?
      errors_array << "Id from response is not an Integer."
    end

    assert_empty errors_array
  end

  def check_sports(expected_data, data_from_api)
    expected_sports = expected_data[:sports]
    expected_sport_ids = []

    expected_sports.each do |_key, value|
      expected_sport_ids << value
    end

    actual_event_operator_sports = data_from_api['data']['sports']
    actual_sport_ids = []

    actual_event_operator_sports.each do |_key, value|
      actual_sport_ids << value
    end

    errors_array = []
    actual_sport_ids.each do |id|
      errors_array << "Unexpected sport id #{id}" unless expected_sport_ids.include? id
    end

    errors_array
  end

  def test_create_read_update_event_operator
    @original_data = event_operator_data
    new_event_operator = create_event_operator
    check_creation(new_event_operator)

    newly_created_event_operator = get_my_event_operator
    read_event_operator(@original_data, newly_created_event_operator)

    updated_event_operator_data = event_operator_data
    update_event_operator(updated_event_operator_data)
    updated_event_operator = get_my_event_operator
    read_event_operator(updated_event_operator_data, updated_event_operator)
  end
end
