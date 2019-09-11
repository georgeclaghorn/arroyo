require "arroyo/stream"

module Arroyo
  class Service
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def download(key)
      client.get(key) do |response|
        if response.status.ok?
          yield Stream.new(response.body)
        else
          raise Error, "Unexpected response status"
        end
      end
    end
  end
end
