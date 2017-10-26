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

  def get(url)
    RestClient.get url
  end

  def pget(url)
    response = get(url)
    [response.code, parse(response)]
  end

  def put(url, body)
    RestClient.put url, body
  end

  def pput(url, body)
    response = put(url, body)
    [response.code, parse(response)]
  end

  def post(url, body)
    RestClient.post url, body
  end

  def ppost(url, body)
    response = post(url, body)
    [response.code, parse(response)]
  end

  def delete(url)
    RestClient.delete url
  end

  def pdelete(url)
    response = delete(url)
    [response.code, parse(response)]
  end
end
