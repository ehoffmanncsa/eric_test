# encoding: utf-8
require_relative 'api'

class TEDAuth
	def initialize(role = nil, username = nil, password = nil)
		@api = Api.new
		creds = Default.env_config

		if role.nil?
			@username = username
			@password = password
		else
			case role
			when 'partner'
				@username = creds['ted']['partner_username']
				@password = creds['ted']['partner_password']
			when 'prem_coach'
				puts 'prem coach???'
				@username = creds['ted']['prem_username']
				@password = creds['ted']['prem_password']
			when 'free_coach'
				@username = creds['ted']['free_username']
				@password = creds['ted']['free_password']
			when 'unverified_coach'
				@username = creds['ted']['unverified_username']
				@password = creds['ted']['unverified_password']
			end
		end
	end

	def request_session
		header = { 'Content-Type' => 'application/vnd.api+json' }
		params = { data: {
					 type: 'sessions',
					 attributes: { email: @username, password: @password }
				   }
				 }.to_json

		staging_url = Default.env_config['ted']['api_base'] + 'sign_in'
		resp_code, resp = @api.ppost staging_url, params, header
		msg = "[ERROR] Get #{resp_code} requesting for #{@username} session token"
		raise msg unless resp_code.eql? 200

		resp
	end

	def get_token
		token = request_session['data']['attributes']['token']
	end
end
