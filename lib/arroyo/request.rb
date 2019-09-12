require "http"

module Arroyo
  class Request
    attr_reader :method, :url, :body

    def initialize(method:, url:, body: nil, signer:)
      @method = method
      @url    = url
      @body   = body
      @signer = signer
    end

    def perform
      HTTP.request method, url, headers: signature.headers, body: body
    end

    private
      def signature
        @signer.sign_request http_method: method, url: url, headers: {}, body: body || ""
      end
  end
end
