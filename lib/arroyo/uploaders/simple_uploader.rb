module Arroyo
  class SimpleUploader
    attr_reader :upload
    delegate :session, :key, :source, to: :upload

    def initialize(upload)
      @upload = upload
    end

    def call
      session.put(key, body: source).then do |response|
        response.status.ok? || raise(Error, "Unexpected response status")
      end
    end
  end
end
