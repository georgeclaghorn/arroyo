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

  test "deleting" do
    request = stub_request(:delete, "https://baz.s3.amazonaws.com/file.txt").to_return(status: 204)
    @bucket.delete "file.txt"
    assert_requested request
  end
end
