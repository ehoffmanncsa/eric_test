require_relative '../test_helper'

=begin
  Ops Messaging Service regression test for its API endpoints.
=end

class HelpScoutApiPostGetTest < Minitest::Test
  MAILBOXES_URL = '/api/ops_messaging/v1/ncsa/mailbox_slug'
  WEB_HOOK_URL = '/api/ops_messaging/v1/help_scout/web_hook'
  CUSTOMER_SIDEBAR_URL = '/api/ops_messaging/v1/help_scout/customer_sidebar'
  EXPECTED_SIDEBAR_HTML = {'html' => '<h4>No Data Found</h4>'}
  EXPECTED_RESPONSE_CODE = '200'

  def setup
    @auth_adapter = FaradayClient.new(account: account, api_key: api_key).adapter
    @help_scout_hmac_client = HelpScoutHmacClient.new(base_uri: base_uri)
  end

  def test_help_scout_api_get
    response = auth_adapter.get do |request|
      request.url(base_uri + MAILBOXES_URL + query_params)
      request.headers['Content-Type'] = 'application/json'
    end

    assert_equal(expected_mailbox_slug, JSON.parse(response.body))
  end

  def test_help_scout_api_post_web_hook
    response = help_scout_hmac_client.post(url: WEB_HOOK_URL)

    assert_equal(EXPECTED_RESPONSE_CODE, response.code)
  end

  def test_help_scout_api_post_custom_side_bar
    body = {'customer' => {'email' => athlete_email}}
    count = 0

    begin
      response = help_scout_hmac_client.post(url: CUSTOMER_SIDEBAR_URL, body: body)
      response_body = JSON.parse(response.body)
    rescue
      count += 1
      print "Retrying after 10 second timeout from HelpScout and 2 seconds from here."
      sleep 2

      retry if count < 5
    end

    assert_equal(EXPECTED_RESPONSE_CODE, response.code)
    assert_equal(EXPECTED_SIDEBAR_HTML, response_body)
  end

  private
  attr_reader :auth_adapter, :help_scout_hmac_client

  def query_params
    "?email=#{help_scout_coach_email}"
  end

  def account
    ENV['NCSA_HELPSCOUT_ACCOUNT']
  end

  def api_key
    ENV['NCSA_HELPSCOUT_API_KEY']
  end

  def base_uri
    credentials['base_uri']
  end

  def help_scout_coach_email
    credentials['coach_email']
  end

  def athlete_email
    MakeRandom.fake_email
  end

  def expected_mailbox_slug
    helpscout_credentials['coach_ehoffman_mailbox_slug']
  end

  def credentials
    Default.env_config['ops_messaging']
  end

  def helpscout_credentials
    Default.env_config['helpscout']
  end
end
