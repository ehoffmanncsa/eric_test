# encoding: utf-8
require 'rest-client'
require 'json'

class Api
  def initialize; end

  # return JSON from the provided HTTP response.body
  def parse(response, element = nil)
    if element
      return JSON.parse("#{response}")["#{element}"]
    else
      return JSON.parse("#{response}")
    end
  end

  def get(url, header = nil)
    RestClient.get url, header
  end

  def pget(url, header = nil)
    response = get(url, header)
    [response.code, parse(response)]
  end

  def put(url, body, header = nil)
    RestClient.put url, body, header
  end

  def pput(url, body, header = nil)
    response = put(url, body, header)
    [response.code, parse(response)]
  end

  def post(url, body, header = nil)
    RestClient.post url, body, header
  end

  def ppost(url, body, header = nil)
    response = post(url, body, header)
    [response.code, parse(response)]
  end

  def delete(url, header = nil)
    RestClient.delete url, header
  end

  def pdelete(url, header = nil)
    response = delete(url, header)
    [response.code, parse(response)]
  end
end
