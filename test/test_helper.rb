# encoding: utf-8
#!/usr/bin/ruby

require 'minitest/autorun'
require 'pp'
require 'yaml'
require 'minitest-ci'
require 'json'
require 'openssl'
require 'net/http'
require 'time'
require 'securerandom'
require 'watir'
require 'watir-scroll'
require 'csv'
require 'jwt'
require 'time'
require 'ffaker'
require 'pry'
require 'faraday'
require 'ey-hmac/faraday'
require_relative 'common'
require_relative 'visual_common'

Minitest::Ci.clean = false

Dir.glob(File.expand_path('../../lib/*.rb', __FILE__)) { |f| require_relative f }
Dir.glob(File.expand_path('../../lib/helpers/*.rb', __FILE__)) { |f| require_relative f }

module Default
  def self.env_config
    ENV['ENV_NAME'] ||= 'staging'
    file_path = File.expand_path("../../config/#{ENV['ENV_NAME']}.yml", __FILE__)
    YAML.load(File.open(file_path))
  end

  def self.static_info
    file_path = File.expand_path('../../config/static_info.yml', __FILE__)
    YAML.load(File.open(file_path))
  end
end
