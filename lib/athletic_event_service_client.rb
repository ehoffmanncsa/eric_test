require 'json'
require 'faraday'
require 'ey-hmac/faraday'

class AthleticEventServiceClient
  def initialize
    @client = create_client
  end

  def post(url:, json_body:)
    response = client.post do |req|
      req.url(base_uri + url)
      req.headers['Content-Type'] = 'application/json'
      req.body = json_body
    end

    JSON.parse(response.body)
  end

  private

  attr_reader :client

  def account
    "ncsa"
  end

  def api_key
    "26d11c0ddc892821496cec3c2e"
  end

  def base_uri
    "http://data-staging.ncsasports.org"
  end

  def create_client
    Faraday.new(ssl: {verify: false}) do |c|
      c.use :hmac, account, api_key, sign_with: :sha256
      c.adapter(Faraday.default_adapter)
    end
  end
end




# require 'pry'
# require 'net/http'
# require 'uri'
# require 'json'

#
# base = "http://data-staging.ncsasports.org"
# acc = "ncsa"
# key = "26d11c0ddc892821496cec3c2e"
#
# http_client = Faraday.new(ssl: {verify: false}) do |c|
#   c.use :hmac, acc, key, sign_with: :sha256
#   c.adapter(Faraday.default_adapter)
# end
#
# body = {
#   event_operator: {
#     name: "test",
#     primary_email: "primary@primary.com",
#     logo_url: "www.logo_url.com",
#     website_url: "https://somewebsiteurl.com",
#   }
# }.to_json
#
# resp = http_client.post do |req|
#   req.url(base + "/api/athletic_events/v1/event_operators")
#   req.headers['Content-Type'] = 'application/json'
#   req.body = body
# end
#
# response = JSON.parse(resp.body)
#
# binding.pry
#
# response
