require_relative '../test_helper'
require 'time'

# CLIVE-21, CLIVE-22

=begin
Sample Expected Response
{"data"=>
  {"website"=>"http://windler.nu",
   "status"=>"Activated",
   "state"=>"DE",
   "start_date"=>"2019-01-29T00:00:00Z",
   "sports"=>[{"sport_name"=>"Basketball (M)", "ncsa_id"=>17638}],
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

class AthleticEventTest < Minitest::Test
  def setup
    @connection_client = AthleticEventServiceClient.new
    @athletic_event_data = athletic_event_data
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
                              json_body: @athletic_event_data.to_json)
                          rescue => e
                            puts "Gets error #{e} \nWhen POST to v1/athletic_events, going to retry"
                            sleep 2
                            retry if (retries += 1) < 2
                          end
  end

  def check_creation
    refute_empty @new_athletic_event, "POST to 'v1/athletic_events' response is empty"

    msg = 'Created data doesnt have same name as POST request'
    assert_equal @new_athletic_event['data']['name'],
      @athletic_event_data[:athletic_event][:name], msg
  end

  def get_creation
    url = "/api/athletic_events/v1/athletic_events/#{@new_athletic_event['data']['id']}"
    expected_data = @athletic_event_data[:athletic_event]

    @connection_client.get(url: url)
  end

  def read_athletic_event
    event = get_creation

    errors_array = []

    expected_data.each do |key, value|
      next if key == :locations || key == :sports

      msg = "Expected #{key.to_s} #{value}, returned #{event.dig("data", "#{key}")}."
      errors_array << msg unless expected_data[:"#{key}"].eql? event.dig("data", "#{key}")
    end

    check_sports

    check_locations

    if !event.dig("data", "id").integer?
      errors_array << "Id from response is not an Integer."
    end

    assert_empty errors_array
  end

  def check_sports
    event = get_creation

    errors_array = []

    expected_sport = expected_data[:sports]
    event_sport = event['data']['sports']

    i = 0
    expected_sport.each do |sport|
      id = sport[:ncsa_id]

      msg = "Expected sport id #{id}, returned #{event_sport["#{i}"][:ncsa_id]}."
      errors_array << msg unless expected_sport[i][:ncsa_id].eql? event_sport["#{i}"][:ncsa_id]

      i += 1
    end

    assert_empty errors_array
  end

  def check_locations
    expected_location = expected_data[:locations].first
    event_location = event['data']['locations'].first
    expected_location.each do |key, value|
      msg = "Expected #{key.to_s} #{value}, returned #{event_location.dig("#{key}")}."
      errors_array << msg unless expected_location[:"#{key}"].eql? event_location.dig("#{key}")
    end
  end

  def test_create_read_athletic_event
    create_athletic_event
    check_creation

    read_athletic_event
  end
end
