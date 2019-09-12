require "aws-sigv4"

module Arroyo
  class Credentials
    attr_reader :access_key_id, :secret_access_key

    def initialize(access_key_id:, secret_access_key:)
      @access_key_id, @secret_access_key = access_key_id, secret_access_key
    end

    def signer_for(region:, service: "s3")
      Aws::Sigv4::Signer.new \
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key,
        region:            region,
        service:           service
    end
  end
end
