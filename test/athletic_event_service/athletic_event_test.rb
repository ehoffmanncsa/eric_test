require_relative '../test_helper'
require 'time'

=begin
Sample Expected Response
{:age_range=>"15-16",
 :description=>"Ea sunt perspiciatis eum quam est.",
 :end_date=>"2019-01-08T15:07:58-08:00",
 :start_date=>"2019-01-08T15:07:58-08:00",
 :name=>"Bogisich-Rolfson",
 :point_of_contact_email=>"ariana@lesch.name",
 :point_of_contact_name=>"Ernie Lesch",
 :registration_link=>"http://shields.nu",
 :website=>"http://kirlin.se",
 :city=>"New Samuel",
 :state=>"PA",
 :logo_url=>"http://stromancole.com",
 :coach_live_approved=>true,
 :event_operator_id=>72,
 :sports=>
  [{:ncsa_id=>17634},
   {:ncsa_id=>17683},
   {:ncsa_id=>17684},
   {:ncsa_id=>17638}],
 :locations=>
  [{:address1=>"4500 Cliffside Court",
    :address2=>"field 1",
    :city=>"Fort Collins",
    :country=>"USA",
    :name=>"Location4",
    :state=>"CO",
    :zip=>"80526"}]
}
=end

class AthleticEventTest < Minitest::Test
  def setup
    @connection_client = AthleticEventServiceClient.new
  end

  def get_EO_id
    url = "/api/athletic_events/v1/event_operators"
    event = @connection_client.get(url: url)['data'].sample # get random event

    event['id']
  end

  def get_sport_id
    url = "/api/athletic_events/v1/sports"
    event = @connection_client.get(url: url)['data'].sample # get random sport

    event['id']
  end

  def date(days_from_now = 0)
    (DateTime.parse((Date.today + days_from_now).iso8601)).to_s
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

  def athletic_event_data
    {
      age_range: MakeRandom.age_range,
      description: MakeRandom.lorem(rand(1 .. 4)),
      end_date: date(rand(1 .. 7)),
      start_date: date,
      name: MakeRandom.company_name,
      point_of_contact_email: MakeRandom.fake_email,
      point_of_contact_name: "#{MakeRandom.first_name} " + "#{MakeRandom.last_name}",
      registration_link: MakeRandom.url,
      website: MakeRandom.url,
      city: MakeRandom.city,
      state: MakeRandom.state,
      logo_url: MakeRandom.url,
      coach_live_approved: true,
      event_operator_id: get_EO_id,
      sports: sport_ids,
      locations: [
        {
          address1: '4500 Cliffside Court',
          address2: 'field 1',
          city: 'Fort Collins',
          country: 'USA',
          name: 'Location4',
          state: 'CO',
          zip: '80526'
        }
      ]
    }
  end


  def create_athletic_event
    binding.pry

    @new_athletic_event = @connection_client.post(
      url: "/api/athletic_events/v1/athletic_events",
      json_body: athletic_event_data.to_json
    )

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
    # read_athletic_event
  end
end
