# encoding: utf-8

# 1. post to the login api with email / password credentials
  # a. the response will have a json web token, we will want to save this

# 2. on any subsequent request (i.e. to the graphql endpoint) we will include the
#    token within the Authorization header as "Bearer #{token}"

# 3. use response how ever we want

require_relative 'api'

class CoachLiveAuth
	def initialize(username = nil, password = nil)
		@api = Api.new

		@creds = Default.env_config

		@username = username.nil? ? @creds['coachlive']['email'] : username
		@password = password.nil? ? @creds['coachlive']['password'] : password
	end

	def token
		login_endpoint = @creds['coachlive']['base_url'] + 'auth/login'
    params = { email: @username, password: @password }

		resp_code, resp = @api.ppost login_endpoint, params
 
		msg = "[ERROR] Get #{resp_code} requesting for #{@username} session token"
		raise msg unless resp_code.eql? 200

		resp['token']
	end
end
