module Arroyo
  class Stream
    def initialize(source)
      @source = source
    end

    # Public: Read at most `length` bytes from the stream, blocking only if it has no data immediately
    # available. If the stream has any data available, this method does not block.
    #
    # length - the maximum number of bytes to read (optional; default is 16 KB)
    #
    # Returns String data from the stream or nil if EOF has been reached.
    def readpartial(*args)
      @source.readpartial(*args)
    end

    # Public: Iterate over chunks of String data as they're read from the stream.
    #
    # length - the maximum number of bytes to read in each iteration (optional; default is 16 KB)
    #
    # Returns nothing.
    def each(*args)
      while chunk = readpartial(*args)
        yield chunk
      end
    end

    # Public: Copy stream data to the given destination.
    #
    # destination - a File, IO, String path, or IO-like object responding to #write
    #
    # Returns nothing.
    def copy_to(destination)
      IO.copy_stream self, destination
    end
  end
end
