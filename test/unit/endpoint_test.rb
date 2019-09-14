require "test_helper"

class Arroyo::EndpointTest < ActiveSupport::TestCase
  setup do
    @endpoint = Arroyo::Endpoint.new(scheme: "https", host: "foo.s3.amazonaws.com")
  end

  test "scheme validation" do
    error = assert_raises ArgumentError do
      Arroyo::Endpoint.new(scheme: "ftp", host: "s3.amazonaws.com")
    end

    assert_equal 'Unsupported scheme: "ftp"', error.message
  end

  test "host validation" do
    error = assert_raises ArgumentError do
      Arroyo::Endpoint.new(scheme: "https", host: nil)
    end

    assert_equal 'Expected host, got nil', error.message
  end

  test "base URL" do
    assert_equal "https://foo.s3.amazonaws.com", @endpoint.base.to_s
  end

  test "URL for path" do
    assert_equal "https://foo.s3.amazonaws.com/bar.txt",       @endpoint.url_for("bar.txt").to_s
    assert_equal "https://foo.s3.amazonaws.com/bar.txt",       @endpoint.url_for("/bar.txt").to_s
    assert_equal "https://foo.s3.amazonaws.com/bar/baz.txt",   @endpoint.url_for("/bar/baz.txt").to_s
    assert_equal "https://foo.s3.amazonaws.com/bar%20baz.txt", @endpoint.url_for("/bar baz.txt").to_s
    assert_equal "https://foo.s3.amazonaws.com/bar%3Fbaz.txt", @endpoint.url_for("/bar?baz.txt").to_s
  end

  test "URL for path and query" do
    assert_equal "https://foo.s3.amazonaws.com/bar.txt?upload=true",
      @endpoint.url_for("bar.txt", upload: true).to_s
  end
end
