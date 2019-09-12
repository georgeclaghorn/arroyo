require "arroyo/request"

module Arroyo
  class Interface
    def initialize(credentials:, region:, bucket:)
      @credentials = credentials
      @region      = region
      @bucket      = bucket
    end

    def get(path)
      perform :get, path
    end

    def put(path, body: nil)
      perform :put, path, body: body
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
        "https://#{@bucket}.s3.amazonaws.com/" + path.remove(/\A\//)
      end

      def signer
        @signer ||= @credentials.signer_for(region: @region)
      end
  end
end
