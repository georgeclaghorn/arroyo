require "arroyo/reader"

module Arroyo
  class Service
    attr_reader :session

    def initialize(session)
      @session = session
    end

    def download(key)
      session.get(key).then do |response|
        if response.status.ok?
          yield Reader.new(response.body)
        else
          raise Error, "Unexpected response status"
        end
      end
    end

    def upload(key, io)
      session.put(key, body: io).then do |response|
        response.status.ok? || raise(Error, "Unexpected response status")
      end
    end

    def delete(key)
      session.delete(key).then do |response|
        response.status.success? || raise(Error, "Unexpected response status")
      end
    end
  end
end
