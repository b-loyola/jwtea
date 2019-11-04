# frozen_string_literal: true

module JWTea
  module Stores
    class NullStore
      def save(_key, _value, _ttl_in_seconds)
        nil
      end

      def exists?(_key, _value)
        true
      end

      def delete(_key)
        nil
      end
    end
  end
end
