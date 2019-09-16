require "arroyo/uploaders"

module Arroyo
  class Upload
    attr_reader :key, :source
    delegate :size, to: :source

    def initialize(key:, source:)
      @key    = key
      @source = source
    end

    def perform(**kwargs)
      uploader_for(**kwargs).call
    end

    private
      def uploader_for(session:, executor:)
        if size < 10.megabytes
          SimpleUploader.new session: session, upload: self
        else
          MultipartUploader.new session: session, executor: executor, upload: self
        end
      end
  end
end
