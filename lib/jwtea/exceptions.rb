module JWTea
  class Error < StandardError; end
  class StoreNotDefinedError < Error; end
  class MissingJtiError < Error; end
  class MissingExpError < Error; end
  class InvalidToken < Error; end
  class TokenAlreadyGenerated < Error; end
end
