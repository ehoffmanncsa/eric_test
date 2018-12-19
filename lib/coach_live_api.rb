# api = Api.new
#
# response = api.post("https://data-staging.ncsasports.org/api/coachlive-be/auth/login")


# 1. post to the login api with email / password credentials
  # a. the response will have a json web token, we will want to save this

# 2. on any subsequent request (i.e. to the graphql endpoint) we will include the
#    token within the Authorization header as "Bearer #{token}"

# 3. use response how ever we want


# encoding: utf-8
require_relative '../test/test_helper'
require_relative 'api'
require 'pry'

class CoachLiveAuth

	def initialize(username = nil, password = nil)
		@api = Api.new
		@creds = Default.env_config
	end

	def request_session
    ## 'Content-Type' => 'application/x-www-form-urlencoded'
    #header = { 'Content-Type' => 'application/x-www-form-urlencoded' }
		# params = { email: @creds['coachlive']['email'], password: @creds['coachlive']['password'] }.to_json
    params = { email: 'email@email.com', password: 'password' }

		staging_url = "https://data-staging.ncsasports.org/api/coachlive-be/auth/login" #Default.env_config['coachlive']['base_url'] + 'auth/login'

		resp = @api.ppost(staging_url, params)
    pp resp
    #binding.pry
		msg = "[ERROR] Get #{resp_code} requesting for #{@username} session token"
		raise msg unless resp_code.eql? 200

		resp
	end
end

CoachLiveAuth.new.request_session
