require "arroyo/api/request"

module Arroyo
  module API
    class Client
      def initialize(credentials:, region:, bucket:)
        @credentials = credentials
        @region      = region
        @bucket      = bucket
      end

      def get(path)
        perform :get, path
      end

      private
        def perform(method, path)
          Request.new(method: method, url: url_for(path), signer: signer).perform
        end

        def url_for(path)
          "https://#{@bucket}.s3.amazonaws.com/" + path.remove(/\A\//)
        end

        def signer
          @signer ||= @credentials.signer_for(region: @region)
        end
    end
  end
end
