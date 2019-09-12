require "arroyo/credentials"
require "arroyo/buckets"
require "arroyo/service"
require "arroyo/api/client"

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
      Service.new client_for(bucket: bucket)
    end

    private
      def client_for(bucket:)
        API::Client.new credentials: @credentials, region: @region, bucket: bucket
      end
  end
end
