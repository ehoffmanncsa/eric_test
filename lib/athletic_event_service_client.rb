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
