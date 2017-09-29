# encoding: utf-8
require 'minitest/autorun'
require 'pp'
require 'yaml'
require 'parallel'
require 'faraday'
require 'mechanize'
require 'minitest-ci'
require 'json'

Minitest::Ci.clean = false

Dir.glob(File.expand_path('../../lib/**/*.rb', __FILE__)) { |f| require_relative f }
