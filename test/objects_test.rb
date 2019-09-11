require "test_helper"

class Arroyo::ObjectsTest < ActiveSupport::TestCase
  setup do
    @client = Arroyo::Client.new(access_key_id: "foo", secret_access_key: "bar", region: "us-east-1")
    @bucket = @client.buckets.open("baz")
  end

  test "downloading" do
    stub_request(:get, "https://baz.s3.amazonaws.com/file.txt")
      .to_return(status: 200, body: "Hello world!")

    checksum = Digest::SHA256.new.tap do |digest|
      @bucket.download("file.txt") do |io|
        io.each { |chunk| digest << chunk }
      end
    end.base64digest

    assert_equal Digest::SHA256.base64digest("Hello world!"), checksum
  end
end
