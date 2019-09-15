require "test_helper"

class Arroyo::SessionTest < ActiveSupport::TestCase
  setup do
    @session = Arroyo::Session.new \
      credentials: Arroyo::Credentials.new(access_key_id: "foo", secret_access_key: "bar"),
      endpoint:    Arroyo::Endpoint.new(scheme: "https", host: "baz.s3.amazonaws.com"),
      region:      "us-east-1"

    travel_to "2019-09-15 12:00:00 UTC"
  end

  test "signed get" do
    stub_request(:get, "https://baz.s3.amazonaws.com/file.txt")
      .to_return(status: 200, body: "Hello world!")

    response = @session.get("file.txt")
    assert response.status.ok?
    assert_equal "Hello world!", response.body.to_s
    assert_requested :get, "https://baz.s3.amazonaws.com/file.txt",
      headers: {
        "Authorization" => /Signature=0d085e52a5ef64572a39c766085186ecfd4191f43cfba72252873bc0f81ea407\z/,
        "X-Amz-Content-Sha256" => "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        "X-Amz-Date" => "20190915T120000Z" }
  end

  test "signed get with query params" do
    stub_request(:get, "https://baz.s3.amazonaws.com/file.txt?glorp=quux")
      .to_return(status: 200, body: "Hello world!")

    response = @session.get([ "file.txt", "glorp" => "quux" ])
    assert response.status.ok?
    assert_equal "Hello world!", response.body.to_s
    assert_requested :get, "https://baz.s3.amazonaws.com/file.txt?glorp=quux",
      headers: { "Authorization" => /Signature=109469176dfcfcb2d2aa4d1980c1f21dc4fa73d8034dba1b02dcac07628b3c69\z/ }
  end

  test "signed put" do
    stub_request(:put, "https://baz.s3.amazonaws.com/file.txt").to_return(status: 200)

    response = @session.put("file.txt", body: "Hello world!")
    assert response.status.ok?
    assert_requested :put, "https://baz.s3.amazonaws.com/file.txt",
      headers: {
        "Authorization" => /Signature=efc0d612ee62bfe4f1082b0a663637debe29342997d4af6d8b1f7f879d80ff1e\z/,
        "X-Amz-Content-Sha256" => "c0535e4be2b79ffd93291305436bf889314e4a3faec05ecffcbb7df31ad9e51a",
        "X-Amz-Date" => "20190915T120000Z" },
      body: "Hello world!"
  end

  test "signed put with query params" do
    stub_request(:put, "https://baz.s3.amazonaws.com/file.txt?glorp=quux").to_return(status: 200)

    response = @session.put([ "file.txt", "glorp" => "quux" ], body: "Hello world!")
    assert response.status.ok?
    assert_requested :put, "https://baz.s3.amazonaws.com/file.txt?glorp=quux",
      headers: { "Authorization" => /Signature=ae93e2f7669ce7389174faacf2ad573ef3a7ee3ff9ae8ce66819bcebfcebfb76\z/ }
  end

  test "signed delete" do
    stub_request(:delete, "https://baz.s3.amazonaws.com/file.txt").to_return(status: 204)

    response = @session.delete("file.txt")
    assert response.status.no_content?
    assert_requested :delete, "https://baz.s3.amazonaws.com/file.txt",
      headers: {
        "Authorization" => /Signature=bc698c3b1cb4c17e57f3aa707ccc155c8f64c67051f7779bad1dad7299a28e77\z/,
        "X-Amz-Content-Sha256" => "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        "X-Amz-Date" => "20190915T120000Z" }
  end
end
