require "test_helper"

class Arroyo::ObjectsTest < ActiveSupport::TestCase
  setup do
    @client = Arroyo::Client.new(access_key_id: "foo", secret_access_key: "bar", region: "us-east-1")
    @bucket = @client.buckets.open("baz")
  end

  test "downloading to a path on disk" do
    stub_request(:get, "https://baz.s3.amazonaws.com/file.txt")
      .to_return(status: 200, body: "Hello world!")

    Tempfile.create([ "file", ".txt" ]) do |file|
      @bucket.download "file.txt", file.path
      assert_equal "Hello world!", file.read
    end
  end

  test "downloading to a file" do
    stub_request(:get, "https://baz.s3.amazonaws.com/file.txt")
      .to_return(status: 200, body: "Hello world!")

    Tempfile.create([ "file", ".txt" ]) do |file|
      @bucket.download "file.txt", file

      file.rewind
      assert_equal "Hello world!", file.read
    end
  end

  test "checksumming" do
    stub_request(:get, "https://baz.s3.amazonaws.com/file.txt")
      .to_return(status: 200, body: "Hello world!")

    checksum = Digest::SHA256.new.tap do |digest|
      @bucket.download("file.txt") do |io|
        io.each { |chunk| digest << chunk }
      end
    end.base64digest

    assert_equal Digest::SHA256.base64digest("Hello world!"), checksum
  end

  test "uploading from a path on disk" do
    request = stub_request(:put, "https://baz.s3.amazonaws.com/file.txt")
      .with(body: "Hello world!").to_return(status: 200)

    Tempfile.create([ "file", ".txt" ]) do |file|
      file.write "Hello world!"
      file.flush
      @bucket.upload "file.txt", file.path
    end

    assert_requested request
  end

  test "uploading from a file" do
    request = stub_request(:put, "https://baz.s3.amazonaws.com/file.txt")
      .with(body: "Hello world!").to_return(status: 200)

    Tempfile.create([ "file", ".txt" ]) do |file|
      file.write "Hello world!"
      file.rewind
      @bucket.upload "file.txt", file
    end

    assert_requested request
  end

  test "uploading from a large file in multiple parts" do
    id = "VXBsb2FkIElEIGZvciA2aWWpbmcncyBteS1tb3ZpZS5tMnRzIHVwbG9hZA"
    requests = [
      stub_multipart_upload_initiation_request(key: "starry_night.jpg", id: id),
      stub_upload_part_request(key: "starry_night.jpg", id: id, number: 1, etag: "foo"),
      stub_upload_part_request(key: "starry_night.jpg", id: id, number: 2, etag: "bar"),
      stub_upload_part_request(key: "starry_night.jpg", id: id, number: 3, etag: "baz"),
      stub_multipart_upload_completion_request(key: "starry_night.jpg", id: id)
    ]

    @bucket.upload "starry_night.jpg", file_fixture("starry_night.jpg").open
    requests.each { |request| assert_requested request }
  end

  test "deleting" do
    request = stub_request(:delete, "https://baz.s3.amazonaws.com/file.txt").to_return(status: 204)
    @bucket.delete "file.txt"
    assert_requested request
  end

  private
    def stub_multipart_upload_initiation_request(key:, id:)
      stub_request(:post, "https://baz.s3.amazonaws.com/#{key}?uploads=true")
        .to_return(status: 200, body: <<~XML)
          <?xml version="1.0" encoding="UTF-8"?>
          <InitiateMultipartUploadResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
            <Bucket>baz</Bucket>
            <Key>#{key}</Key>
            <UploadId>#{id}</UploadId>
          </InitiateMultipartUploadResult>
        XML
    end

    def stub_upload_part_request(key:, id:, number:, etag:)
      stub_request(:put, "https://baz.s3.amazonaws.com/starry_night.jpg")
        .with(query: { "uploadId" => id, "partNumber" => number })
        .to_return(status: 200, headers: { "ETag" => etag })
    end

    def stub_multipart_upload_completion_request(key:, id:)
      stub_request(:post, "https://baz.s3.amazonaws.com/#{key}?uploadId=#{id}")
        .to_return(status: 200, body: <<~XML)
          <?xml version="1.0" encoding="UTF-8"?>
          <CompleteMultipartUploadResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
            <Location>http://baz.s3.amazonaws.com/#{key}</Location>
            <Bucket>baz</Bucket>
            <Key>#{key}</Key>
            <ETag>""</ETag>
          </CompleteMultipartUploadResult>
        XML
    end
end
