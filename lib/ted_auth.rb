# encoding: utf-8
require_relative 'api'

class TEDAuth
	def initialize(role = nil, username = nil, password = nil)
		@api = Api.new
		creds = YAML.load_file('config/.creds.yml')

    if role.nil?
      @username = username
      @password = password
    else
  		case role
  		when 'admin'
  			@username = creds['ted_admin']['username']
  			@password = creds['ted_admin']['password']
  		when 'coach'
  			@username = creds['ted_coach']['username']
  			@password = creds['ted_coach']['password']
  		when 'free_coach'
  			@username = creds['ted_coach']['free_username']
  			@password = creds['ted_coach']['password']
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

		staging_url = 'https://qa.ncsasports.org/api/team_edition/sign_in'
		resp_code, resp = @api.ppost staging_url, params, header
		msg = "[ERROR] Get #{resp_code} requesting for #{@username} session token"
		raise msg unless resp_code.eql? 200

		resp
	end

	def get_token
		token = request_session['data']['attributes']['token']
	end
end
