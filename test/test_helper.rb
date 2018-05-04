# encoding: utf-8
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
require_relative 'common'

Minitest::Ci.clean = false

Dir.glob(File.expand_path('../../lib/*.rb', __FILE__)) { |f| require_relative f }
Dir.glob(File.expand_path('../../lib/helpers/*.rb', __FILE__)) { |f| require_relative f }

module Default
  def self.env_config
    ENV['CONFIG_FILE'] ||= 'staging.yml'
    env = ENV['CONFIG_FILE'].split('/').last
    env_path = File.expand_path("../../config/#{env}", __FILE__)
    pp YAML.load(File.open(env_path))
  end

  def self.static_info
    static_path = File.expand_path('../../config/static_info.yml', __FILE__)
    YAML.load(File.open(static_path))
  end
end
