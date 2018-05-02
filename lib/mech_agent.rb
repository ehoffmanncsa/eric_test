# encoding: utf-8
require 'mechanize'
require 'logger'


class MechAgent
  def initialize(url)
    @agent = Mechanize.new
    @agent.log = Logger.new 'mech.log'
    @agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @agent.request_headers = {
      'Accept' => 'text/html',
      'Host' => url
    }

    @agent
  end
end
