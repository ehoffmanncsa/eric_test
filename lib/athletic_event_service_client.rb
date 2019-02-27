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

    msg = "[ERROR] - Receive response #{response.status} when try to POST to #{url}"
    raise msg unless response.status.eql? 201

    JSON.parse(response.body)
  end

  def get(url:)
    response = client.get do |req|
      req.url(base_uri + url)
      req.headers['Content-Type'] = 'application/json'
    end

    msg = "[ERROR] - Receive response #{response.status} when try to GET from #{url}"
    raise msg unless response.status.eql? 200

    JSON.parse(response.body)
  end

  def put(url:, json_body:)
    response = client.put do |req|
      req.url(base_uri + url)
      req.headers['Content-Type'] = 'application/json'
      req.body = json_body
    end

    msg = "[ERROR] - Receive response #{response.status} when try to PUT to #{url}"
    raise msg unless response.status.eql? 200

    JSON.parse(response.body)
  end

  private

  attr_reader :client

  def create_client
    Faraday.new(ssl: {verify: false}) do |c|
      c.use :hmac, account, api_key, sign_with: :sha256
      c.adapter(Faraday.default_adapter)
    end
  end

  def account
    coachlive_credentials['account']
  end

  def api_key
    coachlive_credentials['api_key']
  end

  def base_uri
    coachlive_credentials['base_uri']
  end

  def coachlive_credentials
    Default.env_config['coachlive']
  end
end
