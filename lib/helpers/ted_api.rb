# encoding: utf-8
require_relative '../../test/test_helper'

# This helper is to help in performing TED related actions via API
class TEDApi
  attr_reader :header
  attr_accessor :token

  def initialize(role = nil, token = nil)
    @role = role
    token = token.nil? ? get_token : token
    @base_url = 'https://qa.ncsasports.org/api/team_edition'
    @header = { 'Session-Token' => token, 'Content-Type' => 'application/vnd.api+json' }
    @api = Api.new
  end

  def get_token
    TEDAuth.new(@role).get_token
  end

  def url(endpoint)
    "#{@base_url}/#{endpoint}"
  end

  def read(endpoint)
    resp_code, resp = @api.pget url(endpoint), @header
    msg = "[ERROR] #{resp_code} POST to #{endpoint}"
    raise msg unless resp_code.eql? 200

    resp
  end

  def edit(endpoint, body)
    resp_code, resp = @api.pput url(endpoint), body, @header
    msg = "[ERROR] #{resp_code} POST to #{endpoint}"
    raise msg unless resp_code.eql? 201 # maybe not this code, double check when possible

    resp
  end

  def create(endpoint, body)
    resp_code, resp = @api.ppost url(endpoint), body, @header
    msg = "[ERROR] #{resp_code} POST to #{endpoint}"
    raise msg unless resp_code.eql? 201

    resp
  end

  def delete(endpoint)
    resp_code, resp = @api.pdelete url(endpoint), @header
    msg = "[ERROR] #{resp_code} POST to #{endpoint}"
    raise msg unless resp_code.eql? 200

    resp
  end

  def patch(endpoint, body)
    resp_code, resp = @api.ppatch url(endpoint), body, @header
    msg = "[ERROR] #{resp_code} PATCH to #{endpoint}"
    raise msg unless resp_code.eql? 200

    resp
  end
end
