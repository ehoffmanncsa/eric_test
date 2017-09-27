# encoding: utf-8
require 'minitest/autorun'
require 'pp'
require 'yaml'
require 'parallel'
require 'faraday'
require 'mechanize'
require 'minitest-ci'
require 'minitest/reporters'
require 'json'

Minitest::Ci.clean = false

require_relative '../lib/applitool'
require_relative '../lib/remote_ui'
