module Arroyo
  class Endpoint
    attr_reader :protocol, :host

    def initialize(protocol: "https", host: "s3.amazonaws.com")
      @protocol = protocol.presence_in(%w[ http https ]) || raise(ArgumentError, "Unsupported protocol: #{protocol}")
      @host     = host
    end

    def base_url
      "#{protocol}://#{host}"
    end

    def url_for(path)
      "#{base_url}/#{path.remove(/\A\//)}"
    end
  end
end
