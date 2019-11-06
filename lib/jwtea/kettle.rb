# frozen_string_literal: true
require_relative 'token'
require_relative 'exceptions'

module JWTea
  class Kettle
    delegate :as_json, :to_json, to: :to_h

    def initialize(secret:, store:, algorithm: nil, expires_in: nil)
      @secret = secret
      @store = store
      @algorithm = algorithm || ::JWTea.configuration.default_algorithm
      @expires_in = (expires_in || ::JWTea.configuration.default_expires_in).to_i
    end

    def brew(data)
      exp = @expires_in.seconds.from_now.to_i
      token = ::JWTea::Token.build(data, exp, @secret, @algorithm)
      @store.save(token.jti, token.exp, @expires_in)
      token
    end

    def pour(encoded_token)
      with_token(encoded_token) do |token|
        raise ::JWTea::InvalidToken.new('token revoked') unless token_exists?(token)

        token
      end
    rescue ::JWT::DecodeError => e
      raise ::JWTea::InvalidToken.new(e.message)
    end

    def encode(data)
      token = brew(data)
      token.encoded
    end

    def decode(encoded_token)
      token = pour(encoded_token)
      token.data
    end

    def revoke(encoded_token)
      with_token(encoded_token) { |token| @store.delete(token.jti) }
    end

    def valid?(encoded_token)
      with_token(encoded_token) { |token| token_exists?(token) }
    rescue JWT::DecodeError
      false
    end

    # Prevent sentitive data from being accidentally logged to console
    def inspect
      "#<#{self.class} expires_in: #{@expires_in}, store: #{@store}>"
    end

    # Prevent sentitive data from being accidentally rendered to json
    def to_h
      { expires_in: @expires_in }.freeze
    end

    private

    def token_exists?(token)
      @store.exists?(token.jti, token.exp)
    end

    def with_token(encoded_token)
      token = ::JWTea::Token.load(encoded_token, @secret, @algorithm)
      raise ::JWTea::MissingJtiError unless token.jti
      raise ::JWTea::MissingExpError unless token.exp

      yield(token)
    end
  end
end
