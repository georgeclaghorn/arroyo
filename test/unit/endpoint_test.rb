require "test_helper"

class Arroyo::EndpointTest < ActiveSupport::TestCase
  test "validating protocol" do
    error = assert_raises ArgumentError do
      Arroyo::Endpoint.new(protocol: "ftp", host: "s3.amazonaws.com")
    end

    assert_equal "Unsupported protocol: ftp", error.message
  end

  test "normalizing root" do
    assert_equal "/", Arroyo::Endpoint.new(root: "").root
    assert_equal "/", Arroyo::Endpoint.new(root: "/").root

    assert_equal "/foo/", Arroyo::Endpoint.new(root: "foo").root
    assert_equal "/foo/", Arroyo::Endpoint.new(root: "/foo").root
    assert_equal "/foo/", Arroyo::Endpoint.new(root: "foo/").root
    assert_equal "/foo/", Arroyo::Endpoint.new(root: "/foo/").root
  end

  test "base URL" do
    assert_equal "https://foo.s3.amazonaws.com/",
      Arroyo::Endpoint.new(protocol: "https", host: "foo.s3.amazonaws.com").base_url

    assert_equal "https://foo.s3.amazonaws.com/bar/",
      Arroyo::Endpoint.new(protocol: "https", host: "foo.s3.amazonaws.com", root: "bar").base_url
  end

  test "URL for path" do
    assert_equal "https://foo.s3.amazonaws.com/bar.txt",
      Arroyo::Endpoint.new(protocol: "https", host: "foo.s3.amazonaws.com").url_for("bar.txt")

    assert_equal "https://foo.s3.amazonaws.com/bar/baz.txt",
      Arroyo::Endpoint.new(protocol: "https", host: "foo.s3.amazonaws.com", root: "bar").url_for("baz.txt")
  end
end
