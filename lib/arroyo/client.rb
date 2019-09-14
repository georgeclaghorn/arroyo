require "arroyo/buckets"
require "arroyo/configuration"
require "arroyo/endpoint"
require "arroyo/service"
require "arroyo/session"

module Arroyo
  class Client
    def initialize(**options)
      @configuration = Configuration.new(**options)
    end

    def buckets
      Buckets.new self
    end

    # Internal
    def service_for(bucket:)
      Service.new session_for(bucket: bucket)
    end

    private
      attr_reader :configuration
      delegate :credentials, :region, to: :configuration

      def session_for(bucket:)
        Session.new credentials: credentials, region: region, endpoint: endpoint_for(bucket: bucket)
      end

      def endpoint_for(bucket:)
        Endpoint.new scheme: configuration.scheme, host: "#{bucket}.#{configuration.host}"
      end
  end
end
