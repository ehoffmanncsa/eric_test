# require 'faraday'
# require 'ey-hmac/faraday'
# require 'pry'
# require 'json'
#
# base_uri = 'http://data-staging.ncsasports.org' #ENV.fetch("ATHLETIC_EVENT_SERVICE_BASE_URI")
# auth_id = 'ncsa' #ENV.fetch("ATHLETIC_EVENT_SERVICE_AUTH_ID")
# api_key = '26d11c0ddc892821496cec3c2e' #ENV.fetch("ATHLETIC_EVENT_SERVICE_API_KEY")
#
# # http_client = Faraday.new(base_uri, ssl: {verify: false}) do |c|
# #   c.use :hmac, auth_id, api_key, sign_with: :sha256
# #   c.adapter(Faraday.default_adapter)
# # end
#
# url = '/api/athletic_events/v1/event_operators'
#
# http_client2 = Faraday.new(base_uri + url, ssl: {verify: false}) do |c|
#   c.use :hmac, auth_id, api_key, sign_with: :sha256
#   c.adapter(Faraday.default_adapter)
# end
#
# body = {'website_url'=> 'http://test.tst',
#   'primary_email' => 'zerogravitybasketball1@yopmail.com', "name"=>"Zero Gravity 2"}.to_json
#
# # body = {
# #  :grant_type    => ‘client_credentials’,
# #  :client_id     => client_id,
# #  :client_secret => client_key
# # }
#
# # Case 1: This works
# response = http_client2.post do |req|
#  req.body = body
# end
#
# # body = {'website_url'=> 'http://test.tst',
# #   'primary_email' => 'zerogravitybasketball1@yopmail.com', "name"=>"Zero Gravity 2"}.to_json
#
#
#
# binding.pry
# response = http_client.get(url)




# module AthleticEventService
#   class Client
#     def initialize; end
#
#     # Returns a hash with an array of hashes containing the details of the
#     # events.
#     #
#     #   client = AthleticEventService::Client.new
#     #   client.all_events # => { data: [{ ... }] }
#     #
#     # Options can be included for pagination and filtering:
#     #
#     #   client = AthleticEventService::Client.new
#     #   client.all_events({
#     #     page: {
#     #       number: 1,
#     #       size: 10,
#     #     },
#     #     filter: {
#     #       event_ids: [1,2,3],
#     #       sport_ids: [1,2,3],
#     #     }
#     #   })
#     #   => { data: [{ ... }] }
#     #   TODO: Add pagination details to examples when response from AES is
#     #   known.
#     def all_events(options = {})
#       response = http_client.get("/api/athletic_events/v1/athletic_events#{to_params(options)}")
#       JSON.parse(response.body)
#     rescue Faraday::ConnectionFailed, JSON::ParserError => exception
#       Raven.capture_exception(exception)
#       { "errors" => [exception.message], "status" => (response&.status || 500) }
#     end
#
#     # Returns a hash containing details of the event.
#     #   client = AthleticEventService::Client.new
#     #   client.single_event(1) # => { data: { ... } }
#     def single_event(id)
#       response = http_client.get("/api/athletic_events/v1/athletic_events/#{id}")
#       JSON.parse(response.body)
#     rescue Faraday::ConnectionFailed, JSON::ParserError => exception
#       Raven.capture_exception(exception)
#       { "errors" => [exception.message], "status" => (response&.status || 500) }
#     end
#
#     private
#
#     attr_reader :base_uri, :auth_id, :api_key
#
#     def http_client
#       @_http_client ||= Faraday.new(base_uri, ssl: {verify: false}) do |c|
#         c.use :hmac, auth_id, api_key, sign_with: :sha256
#         c.adapter(Faraday.default_adapter)
#       end
#     end
#
#     def to_params(options)
#       return "" if options.nil? || options.empty?
#       "?#{options.to_query}"
#     end
#   end
# end









# # encoding: utf-8
# #require_relative '../test/test_helper'
# #require_relative 'api'
# #require 'api-auth'
# #require 'faraday'
# require 'json'
# require 'ey-hmac/faraday'
# require 'pp'
#
# @auth_id = 'ncsa'
# @api_key = '26d11c0ddc892821496cec3c2e'
#
# @hostname = 'http://data-staging.ncsasports.org'
# @url = '/api/athletic_events/v1/event_operators'
#
# def http_client
#   @http_client ||= Faraday.new(base_uri, ssl: {verify: false}) do |c|
#     c.use :hmac, @auth_id, @api_key, sign_with: :sha256
#     c.adapter(Faraday.default_adapter)
#   end
# end
#
# def base_uri
#   URI.parse(@hostname)
# end
#
# http_client
# resp = @http_client.get @url
# body = JSON.parse(resp.body)
#
# pp body['data']
#
# # @request = RestClient::Request.new(
# #     url: @url,
# #     method: :get
# # )
# #
# # @signed_request = ApiAuth.sign!(@request, @auth_id, @secret_key, :digest => 'sha256')
# #
# # pp @request
# #
# # pp @signed_request
#
# # class CoachLiveAPI
# # 	def initialize
# # 		@api = Api.new
# #
# #     @hostname = 'http://data-staging.ncsasports.org'
# #     @auth_id = 'ncsa'
# #     @api_key = '26d11c0ddc892821496cec3c2e'
# # 	end
# #
# #   def connection
# #     @connection ||= Faraday.new(base_uri) do |c|
# #       c.use :hmac, auth_id, api_key, sign_with: :sha256
# #
# #       @rack_app.present? ? c.adapter(:rack, @rack_app) : c.adapter(Faraday.default_adapter)
# #     end
# #   end
# #
# #   def base_uri
# #     URI.parse(@hostname)
# #   end
#
