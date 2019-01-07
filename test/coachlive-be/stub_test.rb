require_relative '../test_helper'

class StubTest < Common
  def setup; end

  def teardown; end

  def test_graphql_response
    token = CoachLiveAuth.new.token

    api = Api.new

    header = { 'Content-Type'  => 'application/json', 'Authorization' => "Bearer #{token}" }

    query = <<-HEREDOC
      {
        user {
          id
          email
          name {
            login
            first
            last
          }
          sport
          school {
            name
            title
          }
          events {
            tracking
            attending
          }
        }
      }
    HEREDOC

    body = {
      'query' => query
    }.to_json

    coachlive = Default.env_config['coachlive']

    endpoint = coachlive['base_uri'] + coachlive['coachlive_api'] + 'graphql'
    #endpoint = "http://data-staging.ncsasports.org/api/coachlive-be/graphql"

    resp_code, resp_body = api.pget endpoint, header
    assert_equal 200, resp_code, "GET #{endpoint} gives #{resp_code}"
  end
end
