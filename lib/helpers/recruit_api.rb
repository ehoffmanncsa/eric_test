# encoding: utf-8
require_relative '../../test/test_helper'
require 'json'
require 'securerandom'

class RecruitAPI
  def initialize(enroll_yr = nil)
    @api = Api.new
    @username = "ncsa.automation+#{SecureRandom.hex(2)}"

    @enroll_yr = enroll_yr
    @url = 'https://qa.ncsasports.org/api/submit/v1/new_recruit'
    @sport_ids = [17633, 17634, 17635, 17638, 17639, 17644, 17645, 17652, 17653, 17659, 17660, 
                  17665, 17666, 17683, 17684, 17687, 17688, 17689, 17690, 17691, 17692, 17695, 
                  17696, 17701, 17702, 17706, 17707, 17708, 17711]
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
        grad_yr = MakeRandom.grad_yr
    end

    grad_yr
  end

  def ppost
    grad_yr = year
    body = { recruit: {
               athlete_email: "#{@username}@gmail.com",
               athlete_first_name: MakeRandom.name,
               athlete_last_name: MakeRandom.name,
               athlete_phone: MakeRandom.number(10),
               graduation_year: grad_yr,
               state_code: 'IL',
               sport_id: @sport_ids.sample.to_s,
               event_id: '3285'
              }
            }

    resp_code, resp_body = @api.ppost @url, body
    msg = "[ERROR] Gens #{resp_code} when POST new recruit via API"
    raise msg unless resp_code.eql? 200

    [resp_body, body]
  end
end

#puts RecruitAPI.new.ppost
