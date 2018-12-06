require_relative '../test_helper'

class PingTest < Common
  def setup; end

  def teardown; end

  def test_get_ping_response
    api = Api.new

    response = api.get("https://data-staging.ncsasports.org/api/coachlive-be/ping")

    assert_equal(response.code, 200, "Expected status to be 200, got #{response.code}")
    assert_equal(response.body, "pong", "Expected pong, got #{response.body}")
  end
end
