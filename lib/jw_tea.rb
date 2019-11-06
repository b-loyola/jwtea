# frozen_string_literal: true
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/numeric/time'

require_relative File.join('jw_tea', 'version')
require_relative File.join('jw_tea', 'kettle')
Dir[File.join(File.dirname(__FILE__), 'jw_tea', 'stores', '*.rb')].each {|file| require file }

module JWTea
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= ::JWTea::Configuration.new
    end

    def configure
      yield(configuration)
      configuration
    end
  end

  class Configuration
    DEFAULT_EXPIRES_IN = 3600 # seconds (1 hour)
    DEFAULT_ALGORITHM = 'HS256'

    attr_writer :default_expires_in, :default_algorithm

    def default_expires_in
      @default_expires_in ||= DEFAULT_EXPIRES_IN
    end

    def default_algorithm
      @default_algorithm ||= DEFAULT_ALGORITHM
    end
  end
end
