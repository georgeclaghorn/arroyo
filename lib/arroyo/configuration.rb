require "arroyo/credentials"

module Arroyo
  class Configuration
    attr_reader :credentials, :region, :options

    def initialize(access_key_id:, secret_access_key:, region:, **options)
      @credentials = Credentials.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
      @region      = region
      @options     = options
    end

    def scheme
      options[:scheme] || "https"
    end

    def host
      options[:host] || "s3.amazonaws.com"
    end


    def min_thread_count
      options.dig(:threads, :minimum) || 0
    end

    def max_thread_count
      options.dig(:threads, :maximum) || 10
    end

    def thread_idle_timeout
      options.dig(:threads, :idle_timeout) || 60.seconds
    end
  end
end
