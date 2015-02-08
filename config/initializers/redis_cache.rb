module RedisCache
  class << self
    def connection
      @connection ||= ConnectionPool.new(size: 5, timeout: 5) do
        Redis.new(:url => "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/#{ENV['REDIS_DB']}")
      end
    end
  end
end
