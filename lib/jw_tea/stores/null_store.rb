# frozen_string_literal: true

module JWTea
  module Stores
    class NullStore
      def save(_jti, _exp, _ttl_in_seconds)
        nil
      end

      def exists?(_jti, _exp)
        true
      end

      def delete(_jti)
        nil
      end
    end
  end
end
