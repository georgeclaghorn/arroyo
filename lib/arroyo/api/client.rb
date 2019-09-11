require "arroyo/api/request"
require "aws-sigv4"

module Arroyo
  module API
    class Client
      def initialize(access_key_id:, secret_access_key:, region:, bucket:)
        @access_key_id     = access_key_id
        @secret_access_key = secret_access_key
        @region            = region
        @bucket            = bucket
      end

      def get(path)
        request(:get, path).then { |response| yield response }
      end

      private
        def request(method, path)
          Request.new(method: method, url: url_for(path), signer: signer).perform
        end

        def url_for(path)
          "https://#{@bucket}.s3.amazonaws.com/" + path.remove(/\A\//)
        end

        def signer
          @signer ||= Aws::Sigv4::Signer.new \
            access_key_id:     @access_key_id,
            secret_access_key: @secret_access_key,
            region:            @region,
            service:           "s3"
        end
    end
  end
end
