# encoding: utf-8
require_relative '../../test/test_helper'

class RecruitCreator
  def initialize(enroll_yr = nil)
    @api = Api.new
    @email = "ncsa.automation+#{SecureRandom.hex(2)}@gmail.com"

    # if nothing is passed in, assumed freshman
    @enroll_yr = enroll_yr.nil? ? 'freshman' : enroll_yr
    @url = 'https://qa.ncsasports.org/api/submit/v1/new_recruit'

    @random_sport_id = Default.static_info['sport_ids'].sample
  end

  def year
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
    end

    grad_yr
  end

  def ppost(sport_id = nil)
    grad_yr = year
    sport_id ||= @random_sport_id

    body = { recruit: {
               athlete_email: @email,
               athlete_first_name: MakeRandom.first_name,
               athlete_last_name: MakeRandom.last_name,
               athlete_phone: Default.static_info['gmail']['google_voice'],
               graduation_year: grad_yr,
               state_code: MakeRandom.state,
               zip: MakeRandom.zip_code,
               sport_id: sport_id.to_s,
               event_id: '3285'
              }
            }

    begin
      retries ||= 0
      resp_code, resp_body = @api.ppost @url, body
    rescue
      retry if (retries += 1) < 3
    end

    msg = "[ERROR] #{resp_code} when POST new recruit via API - #{resp_body}"
    raise msg unless resp_code.eql? 200

    pp body
    pp resp_body
    pp "Athete created in this script: #{body[:recruit][:athlete_email]}"
  end

  def main
    sport_id = ARGV[1]
    ppost(sport_id)
  end
end

student_count = ARGV[0].nil? ? 1 : ARGV[0]
for i in 1 .. student_count.to_i
  RecruitCreator.new.main
end
