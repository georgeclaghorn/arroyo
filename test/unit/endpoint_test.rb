require "test_helper"

class Arroyo::EndpointTest < ActiveSupport::TestCase
  setup do
    @endpoint = Arroyo::Endpoint.new(protocol: "https", host: "foo.s3.amazonaws.com")
  end

  test "protocol validation" do
    error = assert_raises ArgumentError do
      Arroyo::Endpoint.new(protocol: "ftp", host: "s3.amazonaws.com")
    end

    assert_equal 'Unsupported protocol: "ftp"', error.message
  end

  test "host validation" do
    error = assert_raises ArgumentError do
      Arroyo::Endpoint.new(protocol: "https", host: nil)
    end

    assert_equal 'Expected host, got nil', error.message
  end

  test "base URL" do
    assert_equal "https://foo.s3.amazonaws.com", @endpoint.base_url
  end

  test "URL for path" do
    assert_equal "https://foo.s3.amazonaws.com/bar.txt",       @endpoint.url_for("bar.txt")
    assert_equal "https://foo.s3.amazonaws.com/bar.txt",       @endpoint.url_for("/bar.txt")
    assert_equal "https://foo.s3.amazonaws.com/bar/baz.txt",   @endpoint.url_for("/bar/baz.txt")
    assert_equal "https://foo.s3.amazonaws.com/bar%20baz.txt", @endpoint.url_for("/bar baz.txt")
  end
end
