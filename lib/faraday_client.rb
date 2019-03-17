class FaradayClient
  def initialize(account:, api_key:)
    @account = account
    @api_key = api_key
  end

  def adapter
    Faraday.new(ssl: {verify: false}) do |c|
      c.use :hmac, account, api_key, sign_with: :sha256
      c.adapter(Faraday.default_adapter)
    end
  end

  private
  attr_reader :account, :api_key
end
