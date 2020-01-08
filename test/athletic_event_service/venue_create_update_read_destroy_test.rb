require_relative '../test_helper'

class VenueCRUDTest < Minitest::Test
  def setup
    @connection_client = AthleticEventServiceClient.new
  end

  def test_create_read_update_destroy_venue
    venue_data = {
      "venue" => {
        "athletic_event_id" => get_an_athletic_event_id,
        "name" => "some venue",
        "address1" => "1333 N Kingsbury",
        "address2" => "4th Floor",
        "city" => "Chicago",
        "state" => "IL",
        "zip" => "60642",
        "country" => "USA",
      }
    }

    created_venue = create_venue(venue_data)
    compare_venue_data(created_venue, venue_data)

    read_venue = read_venue(created_venue["id"])
    compare_venue_data(read_venue, venue_data)

    update_venue_data = {
      "venue" => {
        "athletic_event_id" => get_an_athletic_event_id,
        "name" => "new name",
        "address1" => "new address1",
        "address2" => "new address2",
        "city" => "new city",
        "state" => "WI",
        "zip" => "new zip",
        "country" => "USA",
      }
    }

    update_venue = update_venue(created_venue["id"], update_venue_data)
    compare_venue_data(update_venue, update_venue_data)
    read_venue = read_venue(created_venue["id"])
    compare_venue_data(read_venue, update_venue_data)

    delete_venue(created_venue["id"])
    verify_deletion(created_venue["id"])
  end

  def create_venue(venue_data)
    url = "/api/athletic_events/v1/venues"
    venue = @connection_client.post(url: url, json_body: venue_data.to_json)
    venue["data"]
  end

  def read_venue(venue_id)
    url = "/api/athletic_events/v1/venues/#{venue_id}"
    venue = @connection_client.get(url: url)
    venue["data"]
  end

  def update_venue(venue_id, venue_data)
    url = "/api/athletic_events/v1/venues/#{venue_id}"
    venue = @connection_client.put(url: url, json_body: venue_data.to_json)
    venue["data"]
  end

  def delete_venue(venue_id)
    url = "/api/athletic_events/v1/venues/#{venue_id}"
    @connection_client.delete(url: url)
  end

  def get_an_athletic_event_id
    @_athletic_event_id ||= begin
      url = "/api/athletic_events/v1/athletic_events?page%5Bnumber%5D=1&page%5Bsize%5D=1"
      athletic_event = @connection_client.get(url: url)['data'].first # get queried athletic_event
      athletic_event["id"]
    end
  end

  def compare_venue_data(venue, submitted_venue)
    assert_equal(venue["athletic_event_id"], submitted_venue["venue"]["athletic_event_id"], "POST athletic_event_id does not match RESPONSE athletic_event_id for Venue Creation")
    assert_equal(venue["name"], submitted_venue["venue"]["name"], "POST name does not match RESPONSE name for Venue Creation")
    assert_equal(venue["address1"], submitted_venue["venue"]["address1"], "POST address1 does not match RESPONSE address1 for Venue Creation")
    assert_equal(venue["address2"], submitted_venue["venue"]["address2"], "POST address2 does not match RESPONSE address2 for Venue Creation")
    assert_equal(venue["city"], submitted_venue["venue"]["city"], "POST city does not match RESPONSE city for Venue Creation")
    assert_equal(venue["state"], submitted_venue["venue"]["state"], "POST state does not match RESPONSE state for Venue Creation")
    assert_equal(venue["zip"], submitted_venue["venue"]["zip"], "POST zip does not match RESPONSE zip for Venue Creation")
    assert_equal(venue["country"], submitted_venue["venue"]["country"], "POST country does not match RESPONSE country for Venue Creation")
  end

  def verify_deletion(deleted_venue)
    response = read_venue(deleted_venue)
    assert_equal(response, nil, "DELETE venue is returning data, should be nil")
  end
end
