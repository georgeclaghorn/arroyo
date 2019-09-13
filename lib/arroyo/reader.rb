module Arroyo
  class Reader
    def initialize(stream)
      @stream = stream
    end

    # Public: Read at most `length` bytes from the stream, blocking only if it has no data immediately
    # available. If the stream has any data available, this method does not block.
    #
    # length - the maximum number of bytes to read (optional; default is 16 KB)
    #
    # Returns String data from the stream.
    # Raises EOFError if the end of the stream was previously reached.
    def readpartial(*args)
      @stream.readpartial(*args) || raise(EOFError)
    end

    # Public: Iterate over chunks of String data as they're read from the stream.
    #
    # length - the maximum number of bytes to read in each iteration (optional; default is 16 KB)
    #
    # Returns nothing.
    def each(length = nil)
      buffer = ""

      loop do
        begin
          readpartial length, buffer
        rescue EOFError
          break
        end

        yield buffer
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
