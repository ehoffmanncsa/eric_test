# frozen_string_literal: true

require "uri"
require "delegate"
require "faraday"
require "ey-hmac/faraday"
require 'dotenv/load'

module EmailService
  module ApiClient
    ConnectionError = Class.new(StandardError)
    ResponseError = Class.new(StandardError)

    class Connection
      extend Forwardable

      attr_reader :hostname, :port, :open_timeout, :timeout, :auth_id, :api_key

      def self.instance
        if @test_instance.nil?
          new
        else
          @test_instance
        end
      end

      def self.set_test_instance(instance)
        @test_instance = instance
      end

      def self.clear_test_instance
        @test_instance = nil
      end

      def initialize
        @hostname = "http://data-staging.ncsasports.org"
        @timeout  = 500
        @open_timeout = 100
        @auth_id = get_auth_id
        @api_key = get_api_key
      end

      def connection
        @connection ||= Faraday.new(base_uri) do |c|
          c.use(
            :hmac,
            auth_id,
            api_key,
            sign_with: :sha256
          )

          c.adapter(Faraday.default_adapter)
        end
      end

      def base_uri
        URI.parse(@hostname)
      end

      [:get, :delete, :head].each do |verb|
        define_method(verb) do |url, params = nil, headers = nil, &block|
          unwrapped_repsonse = connection.send(verb, url, params, headers) do |r|
            r.options.timeout = timeout
            r.options.open_timeout = open_timeout

            r.headers["Content-Type"] = "application/json"

            block&.call(r)
          end

          Response.new unwrapped_repsonse
        end
      end

      [:put, :post, :patch].each do |verb|
        define_method(verb) do |url, body = nil, headers = nil, &block|
          unwrapped_response = connection.send(verb, url, body, headers) do |r|
            r.options.timeout = timeout
            r.options.open_timeout = open_timeout
            r.headers["Content-Type"] = "application/json"
            block&.call(r)
          end

          Response.new unwrapped_response
        end
      end

      private

      def get_auth_id
        ENV["EMAIL_SERVICE_AUTH_ID"]
      end

      def get_api_key
        ENV["EMAIL_SERVICE_API_KEY"]
      end
    end

    class Response < SimpleDelegator
      def initialize(faraday_response)
        @faraday_response = faraday_response
        super
        @faraday_response.status
      end
    end
  end
end


conn = EmailService::ApiClient::Connection.new
conn.post("/api/email_service/emails", {
    "email" => {
        "recipients" => {
            "to" => [
                "hsaraiyancsa@gmail.com"
            ]
        },
        "sender" => "noreply@ncsasports.org",
        "body" => "This is to test events.",
        "priority" => "low",
        "metadata" => {},
        "subject" => "This is a test of the NCSA Email Service.",
        "headers" => {
            "X-Mailer" => "EmailService"
        },
        "categories" => ["client_to_coach"]
    }
  }.to_json
)







