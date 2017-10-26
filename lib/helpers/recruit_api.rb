# encoding: utf-8
require 'json'
require 'securerandom'

class RecruitAPI
  def initialize(enroll_yr = nil)
    @api = Api.new
    @username = "automation#{SecureRandom.hex(2)}"

    @enroll_yr = enroll_yr
    @url = 'https://qa.ncsasports.org/api/submit/v1/new_recruit'
    @sport_ids = [17633, 17634, 17635, 17638, 17639, 17644, 17645, 17652, 17653, 17659, 17660, 
                  17665, 17666, 17683, 17684, 17687, 17688, 17689, 17690, 17691, 17692, 17695, 
                  17696, 17701, 17702, 17706, 17707, 17708, 17711]
  end

  def make_name
    charset = Array('a'..'z')
    Array.new(10) { charset.sample }.join
  end

  def make_number(digits)
    charset = Array('0'..'9')
    Array.new(digits) { charset.sample }.join
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
      else
        grad_yr = ((grad_yr - 5) .. (grad_yr + 10)).to_a.sample
    end

    grad_yr
  end

  def ppost
    body = { recruit: {
               athlete_email: "#{@username}@ncsasports.org",
               athlete_first_name: make_name,
               athlete_last_name: make_name,
               athlete_phone: make_number(10),
               graduation_year: year,
               state_code: 'IL',
               sport_id: @sport_ids.sample.to_s,
               event_id: '3285'
              }
            }

    resp_code, resp_body = @api.ppost @url, body

    [resp_code, resp_body, @username]
  end
end

# resp, post, username = RecruitAPI.new.ppost
# puts post, username