require_relative '../test_helper'

class StubTest < Common
  def setup; end

  def teardown; end

  def test_graphql_response
    token = CoachLiveAuth.new.token
    pp token

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
      #variables: variables
    }.to_json

    endpoint = Default.env_config['coachlive']['base_url'] + 'graphql'

    # resp_code, resp_body = api.pget endpoint, header
    # binding.pry
    # assert_equal 200, resp_code, "GET #{endpoint} gives #{resp_code}"


    resp_code, resp_body = api.ppost endpoint, body, header
    binding.pry
    assert_equal 200, resp_code, "POST #{endpoint} gives #{resp_code}"
  end
end
