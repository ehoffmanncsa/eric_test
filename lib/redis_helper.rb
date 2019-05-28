# encoding: utf-8
require 'redis'

class RedisHelper
  attr_reader :client

  def initialize
    @client = client
  end

  def delete(key)
    @client.del(key)
  end

  private

  def client
    Redis.new(
      host: redis_credentials['hostname'],
      port: redis_credentials['port'],
      db: redis_credentials['db']
    )
  end

  def redis_credentials
    Default.env_config['redis']
  end
end
