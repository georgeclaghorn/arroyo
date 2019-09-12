require "arroyo/request"

module Arroyo
  class Interface
    def initialize(credentials:, region:, endpoint:)
      @credentials = credentials
      @region      = region
      @endpoint    = endpoint
    end

    def get(path)
      perform :get, path
    end

    def put(path, body: nil)
      perform :put, path, body: body
    end

    def delete(path)
      perform :delete, path
    end

    private
      def perform(method, path, body: nil)
        Request.new(
          method: method,
          url:    url_for(path),
          body:   body,
          signer: signer
        ).perform
      end

      def url_for(path)
        @endpoint.url_for(path)
      end

      def signer
        @signer ||= @credentials.signer_for(region: @region)
      end
  end
end
