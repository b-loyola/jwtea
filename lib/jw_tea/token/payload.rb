# frozen_string_literal: true
require 'jwt'
require 'forwardable'

module JWTea
  class Token
    class Payload
      attr_reader :data, :exp, :iat, :jti

      class << self
        def from_hash(payload_hash)
          new(payload_hash.transform_keys(&:to_sym))
        end
      end

      extend Forwardable
      def_delegators :to_h, :to_s

      def initialize(data:, exp:, iat: nil, jti: nil)
        @data = data
        @exp = exp
        @iat = iat || Time.current.to_i
        @jti = jti || Digest::MD5.hexdigest([SecureRandom.hex, @iat].join(':'))
      end

      def to_h
        {
          'data' => @data,
          'jti' => @jti,
          'iat' => @iat,
          'exp' => @exp,
        }
      end
    end
  end
end
