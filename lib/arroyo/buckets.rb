require "arroyo/bucket"

module Arroyo
  class Buckets
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def open(name)
      Bucket.new client, name: name
    end
  end
end
