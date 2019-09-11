require "http"

module Arroyo
  module API
    class Request
      attr_reader :method, :url

      def initialize(method:, url:, signer:)
        @method = method
        @url    = url
        @signer = signer
      end

      def perform
        HTTP.request method, url, headers: signature.headers
      end

      private
        def signature
          @signer.sign_request http_method: method, url: url, headers: {}, body: ""
        end
    end
  end
end
