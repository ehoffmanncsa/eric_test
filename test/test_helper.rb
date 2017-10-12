# encoding: utf-8
require 'minitest/autorun'
require 'pp'
require 'yaml'
require 'parallel'
require 'faraday'
require 'mechanize'
require 'minitest-ci'
require 'json'
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

Minitest::Ci.clean = false

Dir.glob(File.expand_path('../../lib/*.rb', __FILE__)) { |f| require_relative f }
Dir.glob(File.expand_path('../../lib/helpers/*.rb', __FILE__)) { |f| require_relative f }
