require_relative '../test_helper'
require 'time'

# CLIVE-21, CLIVE-22, CLIVE-126, CLIVE-127

=begin
Sample Expected Response
{"data"=>
  {"website"=>"http://windler.nu",
   "status"=>"Activated",
   "state"=>"DE",
   "start_date"=>"2019-01-29T00:00:00Z",
   "sports"=>
    [{"sport_name"=>"Basketball (M)",
      "ncsa_id"=>17638}],
   "registration_link"=>"http://hermannhansen.nu",
   "point_of_contact_name"=>"Arnulfo Dach",
   "point_of_contact_email"=>"berna_quigley@cristfadel.ca",
   "name"=>"Weber, Greenholt and Schinner",
   "logo_url"=>"https://demoimages-45r6gc2nv.now.sh/chicago_classic_zg.png",
   "locations"=>
      [{"zip"=>"60910",
        "state"=>"AL",
        "name"=>"djsxhdgbkl",
        "country"=>"USA",
        "city"=>"West Randi",
        "address2"=>"Suite 322",
        "address1"=>"55040 Jacques Grove"}],
   "id"=>118,
   "event_operator_id"=>16,
   "event_operator"=>
      {"website_url"=>"http://hahn.com",
      "primary_email"=>"debroah.lueilwitz@bahringer.info",
      "name"=>"Denesik-Schroeder",
      "logo_url"=>"https://demoimages-45r6gc2nv.now.sh/zg.png",
      "id"=>16},
   "end_date"=>"2019-01-31T00:00:00Z",
   "description"=>
    "Minus repellendus minima exercitationem in unde. Qui cumque placeat error aut magni.",
   "coach_live_approved"=>true,
   "city"=>"Goldnerbury",
   "age_range"=>"18-18",
   "activated_at"=>"2019-01-29T00:00:00Z"}}
=end

class AthleticEventCRUTest < Minitest::Test
  def setup
    @connection_client = AthleticEventServiceClient.new
  end

  def get_EO_id
    url = "/api/athletic_events/v1/event_operators"
    event = @connection_client.get(url: url)['data'].sample # get random event

    event['id']
  end

  def date(days_from_now = 0)
    date = (DateTime.parse((Date.today + days_from_now).iso8601)).to_s
    date.split('+')[0] + 'Z'
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

  def athletic_event_data
    {
      athletic_event: {
        age_range: MakeRandom.age_range,
        description: MakeRandom.lorem(rand(1 .. 4)),
        end_date: date(rand(2 .. 4)),
        start_date: date,
        name: MakeRandom.company_name,
        point_of_contact_email: MakeRandom.fake_email,
        point_of_contact_name: "#{MakeRandom.first_name} " + "#{MakeRandom.last_name}",
        registration_link: MakeRandom.url,
        website: MakeRandom.url,
        city: MakeRandom.city,
        state: MakeRandom.state,
        logo_url: logo_urls,
        coach_live_approved: true,
        status: 'Activated',
        activated_at: date,
        event_operator_id: get_EO_id,
        sports: sport_ids,
        locations: [
          {
            address1: MakeRandom.address,
            address2: MakeRandom.address2,
            city: MakeRandom.city,
            country: 'USA',
            name: MakeRandom.name,
            state: MakeRandom.state,
            zip: MakeRandom.zip_code
          }
        ]
      }
    }
  end

  def create_athletic_event
    @new_athletic_event = begin
                            retries ||= 0
                            @connection_client.post(
                              url: '/api/athletic_events/v1/athletic_events',
                              json_body: @original_data.to_json)
                          rescue => e
                            msg = "#{e} \nPOST body \n#{@original_data} \nGoing to retry"
                            puts msg; sleep 2
                            retry if (retries += 1) < 2
                          end
  end

  def check_creation(new_athletic_event)
    refute_empty @new_athletic_event, "POST to 'v1/athletic_events' response is empty"

    msg = 'Created data doesnt have same name as POST request'
    assert_equal @new_athletic_event['data']['name'],
      @original_data[:athletic_event][:name], msg
  end

  def get_my_event
    url = "/api/athletic_events/v1/athletic_events/#{@new_athletic_event['data']['id']}"
    @connection_client.get(url: url)
  end

  def update_athletic_event(new_data)
    endpoint = "/api/athletic_events/v1/athletic_events/#{@new_athletic_event['data']['id']}"

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

  def read_athletic_event(expected_data, data_from_api)
    errors_array = []

    expected_data = expected_data[:athletic_event]
    expected_data.each do |key, value|
      next if key == :locations || key == :sports

      msg = "Expected #{key.to_s} #{value}, returned #{data_from_api.dig("data", "#{key}")}."
      errors_array << msg unless expected_data[:"#{key}"].eql? data_from_api.dig("data", "#{key}")
    end

    check_sports_result = check_sports(expected_data, data_from_api)
    errors_array << check_sports_result unless check_sports_result.empty?
    errors_array.flatten!

    check_locations_result = check_locations(expected_data, data_from_api)
    errors_array << check_locations_result unless check_locations_result.empty?
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

    actual_athletic_event_sports = data_from_api['data']['sports']
    actual_sport_ids = []

    actual_athletic_event_sports.each do |_key, value|
      actual_sport_ids << value
    end

    errors_array = []
    actual_sport_ids.each do |id|
      errors_array << "Unexpected sport id #{id}" unless expected_sport_ids.include? id
    end

    errors_array
  end

  def check_locations(expected_data, data_from_api)
    errors_array = []

    expected_location = expected_data[:locations]
    event_location = data_from_api['data']['locations']

    i = 0
    expected_location.each do |location|
      location.each do |key, value|
        expected = value
        actual = event_location[i][key.to_s]

        msg = "Expected #{key.to_s} #{expected}, returned #{actual}."
        errors_array << msg unless expected == actual
      end

      i += 1
    end

    errors_array
  end

  def test_create_read_update_athletic_event
    @original_data = athletic_event_data
    new_athletic_event = create_athletic_event
    check_creation(new_athletic_event)

    newly_created_event = get_my_event
    read_athletic_event(@original_data, newly_created_event)

    updated_event_data = athletic_event_data
    update_athletic_event(updated_event_data)
    updated_event = get_my_event
    read_athletic_event(updated_event_data, updated_event)
  end
end
