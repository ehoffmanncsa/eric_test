# encoding: utf-8
require 'minitest/autorun'
require 'pp'
require 'yaml'
require 'minitest-ci'
require 'json'
require 'openssl'
require 'net/http'

Minitest::Ci.clean = false

Dir.glob(File.expand_path('../../lib/*.rb', __FILE__)) { |f| require_relative f }
Dir.glob(File.expand_path('../../lib/helpers/*.rb', __FILE__)) { |f| require_relative f }
