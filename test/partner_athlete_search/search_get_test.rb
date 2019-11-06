require_relative '../test_helper'
require 'pass_client'

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
    ENV['PASS_CLIENT_ENV'] = ENV['ENV_NAME']

    PassClient.configure do |config|
      config.auth_id = account
      config.secret_key = api_key
    end
  end

  def test_is_ncaa_searchable_universal_criteria
    terms = {
      'size' => 1000,
      'is_ncaa_searchable' => true,
      'sport_id' => BASEBALL
    }

    pass_response = PassClient::Athlete::Search.new(search_terms: terms).get

    athletes = JSON.parse(pass_response.body)["data"]["attributes"]

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
      terms = {
        'size' => 1000,
        'is_ncaa_searchable' => true,
        'sport_id' => sport_id
      }

      pass_response = PassClient::Athlete::Search.new(search_terms: terms).get

      athletes = JSON.parse(pass_response.body)["data"]["attributes"]

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

  def test_partner_athletic_range_and_scale
    terms = {
      'size' => 1000,
      'partner_athletic_rating' => {
        'min' => 3.0,
        'max' => 4.5
      },
      'partner_athletic_rating_scale' => 6.0,
      'partner_name' => 'ncsa'
    }

    pass_response = PassClient::Athlete::Search.new(search_terms: terms).get

    athletes = JSON.parse(pass_response.body)["data"]["attributes"]

    failures = []
    athletes.each do |athlete|
      failures << "athletic rating less than 3.0" if athlete["partner_athletic_rating"] < 3.0
      failures << "athletic rating greater than 4.5" if athlete["partner_athletic_rating"] > 4.5
      failures << "athletic rating scale not equal to 6.0" if athlete["partner_athletic_rating_scale"] != 6.0
      failures << "partner name not equal to 'ncsa'" if athlete["partner_name"] != 'ncsa'
    end

    assert_empty(failures)
  end

  private

  def account
    ENV['NCSA_PASS_ACCOUNT']
  end

  def api_key
    ENV['NCSA_PASS_API_KEY']
  end
end
