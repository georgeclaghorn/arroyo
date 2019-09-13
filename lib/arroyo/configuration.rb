require "arroyo/credentials"

module Arroyo
  class Configuration
    attr_reader :credentials, :region, :options

    def initialize(access_key_id:, secret_access_key:, region:, **options)
      @credentials = Credentials.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
      @region      = region
      @options     = options
    end

    def protocol
      options[:protocol] || "https"
    end

    def host
      options[:host] || "s3.amazonaws.com"
    end
  end
end
