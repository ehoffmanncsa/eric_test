# encoding: utf-8
require_relative '../../test/test_helper'
require 'digest'

class RecruitAPI
  def initialize(enroll_yr = nil, sport_id = nil, need_google_voice = false)
    @enroll_yr = enroll_yr
    @sport_id = sport_id.nil? ? Default.static_info['sport_ids'].sample : sport_id
    @need_google_voice = need_google_voice
    EventHelper.setup(@browser)
  end

  def ppost
    first_name = MakeRandom.first_name
    last_name = MakeRandom.last_name
    body = {
      recruit: {
        athlete_email: email(first_name, last_name),
        athlete_first_name: first_name,
        athlete_last_name: last_name,
        athlete_phone: athlete_phone,
        graduation_year: grad_yr,
        state_code: MakeRandom.state,
        zip: MakeRandom.zip_code,
        sport_id: @sport_id.to_s,
        event_id: event_id
        # signed_up_for_ncsa: false # use this for when we need to disable this lead funnel
      }
    }

    begin
      retries ||= 0
      resp_code, resp_body = api.ppost url, body
    rescue => error
      # Duplicated Lead, retrying
      if error.message == "409 Conflict"
        puts "[INFO] Encountering a duplicate... trying again"
        return ppost
      else
        puts error
        sleep 3
        puts "Retrying ..."
        retry if (retries += 1) < 5
      end
    end
    msg = "[ERROR] #{resp_code} when POST new recruit via API - #{resp_body}"
    raise msg unless resp_code.eql? 200

    pp body
    pp resp_body
    puts "Athete created in this script: #{body[:recruit][:athlete_email]}"

    [resp_body, body]
  end

  private

  def api
    Api.new
  end

  def url
    rss = Default.env_config['rss']
    rss['base_url'] + rss['endpoint']
  end

  def grad_yr
    grad_yr = Time.now.year
    month = Time.now.month

    case @enroll_yr
      when 'freshman'
        month > 6 ? grad_yr += 4 : grad_yr += 3
      when 'sophomore'
        month > 6 ? grad_yr += 3 : grad_yr += 2
      when 'junior'
        month > 6 ? grad_yr += 2 : grad_yr += 1
      when 'senior'
        month > 6 ? grad_yr += 1 : grad_yr
      else
        month > 6 ? grad_yr += rand(2 .. 4) : grad_yr += rand(1 .. 4)
    end

    grad_yr
  end

  def email(first_name, last_name)
    dupe_key = "#{first_name[0...3]}#{last_name[0...3]}#{@sport_id}"
    randomized_string = Digest::MD5.hexdigest(dupe_key)[0...4]  + SecureRandom.hex(2)

    "ncsa.automation+#{randomized_string}@gmail.com"
  end

  def athlete_phone
    @need_google_voice ? Default.static_info['gmail']['google_voice'] : MakeRandom.phone_number
  end

  def event_id
    EventHelper.retreive_random_event_id
  end
end
