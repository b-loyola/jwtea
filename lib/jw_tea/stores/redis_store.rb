# frozen_string_literal: true
require 'redis'

module JWTea
  module Stores
    class RedisStore
      OK = 'OK'
      TEMPLATE = 'jti:%<jti>s'

      def initialize(*redis_options)
        @redis = ::Redis.new(*redis_options)
      end

      def save(jti, exp, ttl_in_seconds)
        key = key(jti)
        result = @redis.setex(key, ttl_in_seconds, exp.to_s)
        result == OK
      end

      def exists?(jti, exp)
        key = key(jti)
        @redis.get(key) == exp.to_s
      end

      def delete(jti)
        key = key(jti)
        result = @redis.del(key)
        result == 1
      end

      private

      def key(jti)
        format(TEMPLATE, jti: jti)
      end
    end
  end
end
