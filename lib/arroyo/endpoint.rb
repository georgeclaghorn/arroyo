require "addressable/uri"

module Arroyo
  class Endpoint
    attr_reader :scheme, :host

    def initialize(scheme: "https", host: "s3.amazonaws.com")
      @scheme = scheme.presence_in(%w[ http https ]) || raise(ArgumentError, "Unsupported scheme: #{scheme.inspect}")
      @host   = host.presence || raise(ArgumentError, "Expected host, got #{host.inspect}")
    end

    def base
      @base ||= Addressable::URI.new(scheme: scheme, host: host)
    end

    def url_for(path, **params)
      base.merge(path: path, query: params.to_query).normalize!
    end
  end
end
