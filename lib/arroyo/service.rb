require "arroyo/reader"

module Arroyo
  class Service
    attr_reader :interface

    def initialize(interface)
      @interface = interface
    end

    def download(key)
      interface.get(key).then do |response|
        if response.status.ok?
          yield Reader.new(response.body)
        else
          raise Error, "Unexpected response status"
        end
      end
    end

    def upload(key, io)
      interface.put(key, body: io).then do |response|
        response.status.ok? || raise(Error, "Unexpected response status")
      end
    end

    def delete(key)
      interface.delete(key).then do |response|
        response.status.success? || raise(Error, "Unexpected response status")
      end
    end
  end
end
