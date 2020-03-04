require_relative '../test_helper'

=begin
  CAS regression test for Free Coach View Email
  CAS -> ESS -> SF
=end

class FreeCoachViewEmail < Minitest::Test
  COACH_ACTIVITY_SERVICE_EVENT_URL = "/api/coach_activity/v1/event"
  LIZIOANA_FLORES_PERSON_ID = 12806774
  EXPECTED_CAS_RESPONSE = 201
  SQL_APP = "fasttrack"

  def setup
    @sql = SQLConnection.new(SQL_APP)
    @sql.get_connection

    @auth_adapter = FaradayClient.new(account: account, api_key: api_key).adapter
  end

  def test_free_coach_view_email
    response = @auth_adapter.post(
      base_uri + COACH_ACTIVITY_SERVICE_EVENT_URL,
      json_body
    ) do |request|
      request.headers['Content-Type'] = 'application/json'
    end

    puts "Sleeping for 10 Seconds to allow Rabbit MQ processing."
    sleep(10)

    data = @sql.exec(mktg_email_queue_record).to_a

    new_mktg_email_queue_record_created_at_time = data[0]["created_at"].to_i
    sixty_seconds_ago = Time.now.to_i - 60

    @sql.close_connection

    assert(new_mktg_email_queue_record_created_at_time > sixty_seconds_ago)
    assert_equal(response.status, EXPECTED_CAS_RESPONSE)
  end

  private

  def mktg_email_queue_record
    <<-QUERY

    SELECT
      TOP 1 *
    FROM
      mktg_email_queues
    WHERE
      person_id = #{LIZIOANA_FLORES_PERSON_ID}
    ORDER BY
      created_at DESC

    QUERY
  end

  def json_body
    {
      "occurred_at" => DateTime.now,
      "action" => "view",
      "source_application" => "QA Regression",
      "athlete_id" => 4171498,
      "coach_id" => 264012,
      "detail" => "COACH_QUERY",
      "deleted" => 0,
      "partner_name" => "NCSA",
      "deleted_at" => nil,
      "coach_email" => "ehoffmanncsa@gmail.com",
      "coach_first_name" => "Coach",
      "coach_last_name" => "Hoff",
      "coach_position" => nil,
      "coach_sport" => {"sport_id": 116, "sport_name": "Football", "ncsa_sport_id": 17633, "ncsa_sport_name": "Football"},
      "college_name" => "Illinois State University",
      "iped_id" => 145813,
      "pass_uuid" => nil,
      "athlete_email" => "buddyrflores1@msn.com.tst",
      "athlete_first_name" => "Lizioana (Tiffany)",
      "athlete_last_name" => "Flores",
      "athlete_sport" => {"sport_id": 116, "sport_name": "Football", "ncsa_sport_id": 17633, "ncsa_sport_name": "Football"},
      "hidden" => 0
    }.to_json
  end

  def account
    ENV['NCSA_PASS_ACCOUNT']
  end

  def api_key
    ENV['NCSA_PASS_API_KEY']
  end

  def base_uri
    Default.env_config['aws']['base_uri']
  end
end
