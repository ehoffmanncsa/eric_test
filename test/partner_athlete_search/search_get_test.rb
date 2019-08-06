require_relative '../test_helper'

=begin
  Partner Athlete Search regression search queries.
=end

class PartnerAthleteSearchTest < Minitest::Test
  JSON_WEB_TOKEN_PATH = '/api/partner_athlete_search/v1/issue_token'
  ATHLETE_SEARCH_PATH = '/api/partner_athlete_search/v1/search/athlete'
  BASEBALL = 101
  MENS_BASKETBALL = 102
  WOMENS_BASKETBALL = 103
  FOOTBALL = 116
  SPECIAL_SPORTS = [MENS_BASKETBALL, WOMENS_BASKETBALL, FOOTBALL]

  def setup
    @auth_adapter = FaradayClient.new(account: account, api_key: api_key).adapter
    @jwt = get_json_web_token
  end

  def test_is_ncaa_searchable_universal_criteria
    response = search_athletes({
      'size' => 1000,
      'is_ncaa_searchable' => true,
      'sport_id' => BASEBALL
    })

    athletes = JSON.parse(response.body)["data"]["attributes"]

    failures = []
    athletes.each do |athlete|
      failures << "first_name is nil" if athlete["first_name"].nil?
      failures << "last_name is nil" if athlete["last_name"].nil?
      failures << "high_school_name is nil" if athlete["high_school_name"].nil?
      failures << "primary_position_id is nil" if athlete["primary_position_id"].nil?
    end

    assert_empty(failures)
  end

  def test_is_ncaa_searchable_sport_specific_criteria
    SPECIAL_SPORTS.each do |sport_id|
      response = search_athletes({
        'size' => 1000,
        'is_ncaa_searchable' => true,
        'sport_id' => sport_id
      })

      athletes = JSON.parse(response.body)["data"]["attributes"]

      failures = []
      athletes.each do |athlete|
        failures << "first_name is nil" if athlete["first_name"].nil?
        failures << "last_name is nil" if athlete["last_name"].nil?
        failures << "high_school_name is nil" if athlete["high_school_name"].nil?
        failures << "primary_position_id is nil" if athlete["primary_position_id"].nil?
        if athlete["gpa"].nil? && (athlete["videos"].nil? || athlete["videos"] == {"data" => []}) && (athlete["keystats"].nil? || athlete["keystats"] == {"data" => []})
          failures << "gpa: #{athlete['gpa']} or videos: #{athlete['videos']} or keystats: #{athlete['keystats']} where not present"
        end
      end

      assert_empty(failures)
    end
  end

  private

  def get_json_web_token
    @_get_json_web_token ||= begin
      response = @auth_adapter.post do |request|
        request.headers["Content-Type"] = "application/json"
        request.url(base_uri + JSON_WEB_TOKEN_PATH)
        request.body = {auth_id: account}.to_json
      end

      JSON.parse(response.body)["data"]["attributes"]["token"]
    end
  end

  def search_athletes(params)
    uri = URI(base_uri + ATHLETE_SEARCH_PATH)
    uri.query = URI.encode_www_form(params)

    req = Net::HTTP::Get.new(uri)
    req['Content-Type'] = 'application/json'
    req['Authorization'] = "#{@jwt}"

    Net::HTTP.start(uri.hostname) do |http|
      http.request(req)
    end
  end

  def base_uri
    credentials['base_uri']
  end

  def credentials
    Default.env_config['partner_athlete_search']
  end

  def account
    ENV['NCSA_PASS_ACCOUNT']
  end

  def api_key
    ENV['NCSA_PASS_API_KEY']
  end
end
