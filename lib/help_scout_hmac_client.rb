require 'openssl'
require 'base64'

class HelpScoutHmacClient
  def initialize(base_uri:)
    @base_uri = base_uri
  end

  def post(url:, body: {})
    uri = URI(base_uri + url)
    body = body.to_json
    headers = {
      'Content-Type' => 'application/json',
      'x-helpscout-event' => 'qa_regression',
      'x-helpscout-signature' => hmac_signature(body)
    }

    Net::HTTP.post(uri, body, headers)
  end

  private
  attr_reader :base_uri

  def hmac_signature(data)
    key = ENV['HELPSCOUT_SECRET_KEY']
    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.digest(digest, key, data)

    Base64.encode64("#{hmac}")
  end
end
