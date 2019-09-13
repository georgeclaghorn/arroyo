require "arroyo/buckets"
require "arroyo/credentials"
require "arroyo/endpoint"
require "arroyo/service"
require "arroyo/session"

module Arroyo
  class Client
    def initialize(access_key_id:, secret_access_key:, region:)
      @credentials = Credentials.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
      @region      = region
    end

    def buckets
      Buckets.new self
    end

    # Internal
    def service_for(bucket:)
      Service.new session_for(bucket: bucket)
    end

    private
      def session_for(bucket:)
        Session.new credentials: @credentials, region: @region, endpoint: endpoint_for(bucket: bucket)
      end

      def endpoint_for(bucket:)
        Endpoint.new protocol: "https", host: "#{bucket}.s3.amazonaws.com"
      end
  end
end
