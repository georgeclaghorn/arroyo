module Arroyo
  class Endpoint
    attr_reader :protocol, :host, :root

    def initialize(protocol: "https", host: "s3.amazonaws.com", root: "/")
      @protocol = protocol.presence_in(%w[ http https ]) || raise(ArgumentError, "Unsupported protocol: #{protocol}")
      @host     = host
      @root     = root.gsub(/(\A\/?|(?<!\/)\z)/, "/")
    end

    def base_url
      "#{protocol}://#{host}#{root}"
    end

    def url_for(path)
      base_url + path.remove(/\A\//)
    end
  end
end
