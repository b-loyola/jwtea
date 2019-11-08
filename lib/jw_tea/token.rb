# frozen_string_literal: true
require 'jwt'
require_relative 'token/payload'

module JWTea
  class Token
    class << self
      def load(encoded_token, secret, algorithm)
        payload, _header = ::JWT.decode(encoded_token, secret, true, verify_iat: true, algorithm: algorithm)
        new(payload)
      end

      def build(data, exp, secret, algorithm)
        token = new(data: data, exp: exp)
        token.encoded = ::JWT.encode(token.payload.to_h, secret, algorithm)
        token
      end
    end

    attr_accessor :encoded
    attr_reader :payload
    delegate :data, :exp, :jti, to: :payload

    def initialize(payload)
      @payload = JWTea::Token::Payload.from_hash(payload)
    end

    # Prevent sentitive data from being accidentally logged to console
    def inspect
      to_s
    end

    def key
      @key ||= Digest::MD5.hexdigest(@payload.to_s)
    end
  end
end
