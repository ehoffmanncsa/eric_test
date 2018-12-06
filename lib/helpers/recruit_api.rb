# encoding: utf-8

class RecruitAPI
  def initialize(enroll_yr = nil, sport_id = nil, need_google_voice = false)
    @api = Api.new

    @email = "ncsa.automation+#{SecureRandom.hex(2)}@gmail.com"
    @enroll_yr = enroll_yr

    clientrms = Default.env_config['clientrms']
    @url = clientrms['base_url'] + clientrms['rss_endpoint']

    @sport_id = sport_id.nil? ? Default.static_info['sport_ids'].sample : sport_id
    @need_google_voice = need_google_voice
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
        grad_yr += rand(1 .. 4)
    end

    grad_yr
  end

  def ppost
    athlete_phone = @need_google_voice ? Default.static_info['gmail']['google_voice'] : MakeRandom.phone_number
    event_id = rand(16233 .. 18351).to_s # events between 2017-01-01 and 2019-12-31 in Fasttrack events table

    body = {
      recruit: {
        athlete_email: @email,
        athlete_first_name: MakeRandom.first_name,
        athlete_last_name: MakeRandom.last_name,
        athlete_phone: athlete_phone,
        graduation_year: grad_yr,
        state_code: MakeRandom.state,
        zip: MakeRandom.zip_code,
        sport_id: @sport_id.to_s,
        event_id: event_id
      }
    }

    begin
      retries ||= 0
      resp_code, resp_body = @api.ppost @url, body
    rescue
      retry if (resp_code.nil? && ((retries += 1) < 10))
    end

    msg = "[ERROR] #{resp_code} when POST new recruit via API - #{resp_body}"
    raise msg unless resp_code.eql? 200

    pp body
    pp resp_body
    pp "Athete created in this script: #{body[:recruit][:athlete_email]}"

    [resp_body, body]
  end
end
