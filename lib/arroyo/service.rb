require "arroyo/reader"
require "arroyo/upload"

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

    def upload(key, source)
      Upload.new(session: session, key: key, source: source).perform
    end

    def delete(key)
      session.delete(key).then do |response|
        response.status.success? || raise(Error, "Unexpected response status")
      end
    end
  end
end
