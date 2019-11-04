# frozen_string_literal: true
require 'redis'

module JWTea
  module Stores
    class RedisStore
      OK = 'OK'

      def initialize(*redis_options)
        @redis = ::Redis.new(*redis_options)
      end

      def save(key, value, ttl_in_seconds)
        result = @redis.setex(key, ttl_in_seconds, value.to_s)
        result == OK
      end

      def exists?(key, value)
        @redis.get(key) == value.to_s
      end

      def delete(key)
        result = @redis.del(key)
        result == 1
      end
    end
  end
end
