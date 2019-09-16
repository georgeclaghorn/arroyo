require "arroyo/resource"

module Arroyo
  class MultipartUploader
    attr_reader :upload
    delegate :session, :key, to: :upload

    def initialize(upload)
      @upload = upload
    end

    def call
      initiate

      begin
        partition
      rescue
        abort
        raise
      else
        complete
      end
    end

    private
      def initiate
        post([ key, uploads: true ]).then do |response|
          if response.status.ok?
            extract_id_from(response) || raise(Error, "Response did not include an upload ID")
          else
            raise Error, "Unexpected response status"
          end
        end
      end

      def partition
        parts.collect do |part|
          put([ key, "uploadId" => @id, "partNumber" => part.number ], body: part.body).then do |response|
            if response.status.ok?
              part.etag = response.etag || raise(Error, "Response did not include a part ETag")
            else
              raise Error, "Unexpected response status"
            end
          end
        end
      end

      def abort
        delete([ key, "uploadId" => @id ]).then do |response|
          raise Error, "Couldn't abort multipart upload" unless response.status.success?
        end
      end

      def complete
        post([ key, "uploadId" => @id ],
            body: parts.to_xml(root: "CompleteMultipartUpload", children: "Part", skip_types: true)).then do |response|
          raise Error, "Unexpected response status" unless response.status.success?
        end
      end


      def post(*args)
        Resource.new session.post(*args)
      end

      def put(*args)
        Resource.new session.put(*args)
      end

      def delete(*args)
        Resource.new session.delete(*args)
      end

      def extract_id_from(response)
        @id = response.find("UploadId")&.content
      end


      def parts
        @parts ||= Partitioning.new(upload).parts
      end

      class Partitioning
        attr_reader :upload

        def initialize(upload)
          @upload = upload
        end

        def parts
          1.upto(parts_count).collect { |number| Part.new upload: upload, number: number, size: part_size }
        end

        private
          MAXIMUM_PARTS_COUNT = 10_000
          MINIMUM_PART_SIZE   = 5.megabytes

          def parts_count
            upload.size.fdiv(part_size).ceil
          end

          def part_size
            @part_size ||= [ upload.size.fdiv(MAXIMUM_PARTS_COUNT).ceil, MINIMUM_PART_SIZE ].max
          end
      end

      class Part
        attr_reader :upload, :number, :size
        attr_accessor :etag

        def initialize(upload:, number:, size:)
          @upload = upload
          @number = number
          @size   = size
        end

        def body
          upload.source.pread(size, offset)
        end

        def to_xml(**options)
          { "PartNumber" => number, "ETag" => etag }.to_xml(**options)
        end

        private
          def offset
            (number - 1) * size
          end
      end
  end
end
