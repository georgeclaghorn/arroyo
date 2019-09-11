module Arroyo
  class Bucket
    attr_reader :client, :name

    def initialize(client, name:)
      @client, @name = client, name
    end

    # Public: Download the contents of the object at the given key.
    #
    # If a block is provided, an Arroyo::Stream is yielded to it.
    #
    # When no block is provided, a destination is required. Object data is written to it via IO.copy_stream.
    #
    # key         - the String key of the object to download
    # destination - a File, IO, String path, or IO-like object responding to #write
    #               (required if no block is provided)
    #
    # Examples:
    #
    #   # Download an object to disk:
    #   bucket.download("file.txt", "/path/to/file.txt")
    #
    #
    #   # Compute an object's checksum 5 MB at a time:
    #   checksum = Digest::SHA256.new.tap do |digest|
    #     bucket.download("file.txt") do |io|
    #       io.each(5.megabytes) { |chunk| digest << chunk }
    #     end
    #   end.base64digest
    #
    # Returns the result of evaluating the given block. If no block is provided, returns nothing.
    def download(key, destination = nil)
      service.download(key) do |source|
        if block_given?
          yield source
        else
          source.copy_to(destination)
        end
      end
    end

    private
      def service
        @service ||= client.service_for(bucket: name)
      end
  end
end
