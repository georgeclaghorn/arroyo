require "test_helper"

class Arroyo::EndpointTest < ActiveSupport::TestCase
  test "protocol validation" do
    error = assert_raises ArgumentError do
      Arroyo::Endpoint.new(protocol: "ftp", host: "s3.amazonaws.com")
    end

    assert_equal "Unsupported protocol: ftp", error.message
  end

  test "base URL" do
    assert_equal "https://foo.s3.amazonaws.com",
      Arroyo::Endpoint.new(protocol: "https", host: "foo.s3.amazonaws.com").base_url
  end

  test "URL for path" do
    assert_equal "https://foo.s3.amazonaws.com/bar.txt",
      Arroyo::Endpoint.new(protocol: "https", host: "foo.s3.amazonaws.com").url_for("bar.txt")
    assert_equal "https://foo.s3.amazonaws.com/bar.txt",
      Arroyo::Endpoint.new(protocol: "https", host: "foo.s3.amazonaws.com").url_for("/bar.txt")
  end
end
