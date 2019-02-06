class HelpScoutClient
  def initialize
    @api = Api.new()
  end

  def read(query:)
    @api.pget(base_url + query, header)
  end

  private

  attr_reader :base_url
  attr_reader :header

  def base_url
    helpscout_creds['base_url']
  end

  def header
    {
      'Content-Type' => 'application/json',
      'Authorization'=> "Bearer #{request_access_token}",
    }
  end

  def request_access_token
    url = base_url + 'oauth2/token'
    post_body = {
      'grant_type': 'client_credentials',
      'client_id': "#{app_id}",
      'client_secret': "#{app_secret}"
    }

    _status, response = @api.ppost(url, post_body)

    response['access_token']
  end

  def app_id
    helpscout_creds['app_id']
  end

  def app_secret
    helpscout_creds['app_secret']
  end

  def helpscout_creds
    Default.env_config['helpscout']
  end
end
