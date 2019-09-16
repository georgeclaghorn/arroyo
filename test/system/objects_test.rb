require "system_test_helper"

class Arroyo::ObjectsSystemTest < ActiveSupport::TestCase
  setup { @key = SecureRandom.base58(24) }
  teardown { @bucket.delete @key }

  test "uploading from and downloading to a path on disk" do
    Tempfile.create("up") do |file|
      file.write "Hello world!"
      file.flush
      @bucket.upload @key, file.path
    end

    Tempfile.create("down") do |file|
      @bucket.download @key, file.path
      assert_equal "Hello world!", file.read
    end
  end

  test "uploading from and downloading to a file" do
    Tempfile.create("up") do |file|
      file.write "Hello world!"
      file.rewind
      @bucket.upload @key, file
    end

    Tempfile.create("down") do |file|
      @bucket.download @key, file

      file.rewind
      assert_equal "Hello world!", file.read
    end
  end

  test "checksumming" do
    Tempfile.create("up") do |file|
      file.write "Hello world!"
      file.rewind
      @bucket.upload @key, file
    end

    checksum = Digest::SHA256.new.tap do |digest|
      @bucket.download(@key) do |io|
        io.each { |chunk| digest << chunk }
      end
    end.base64digest

    assert_equal Digest::SHA256.base64digest("Hello world!"), checksum
  end

  test "uploading and downloading binary data" do
    @bucket.upload @key, file_fixture("daisy.jpg").open

    checksum = Digest::SHA256.new.tap do |digest|
      @bucket.download(@key) do |io|
        io.each { |chunk| digest << chunk }
      end
    end.base64digest

    assert_equal Digest::SHA256.file(file_fixture("daisy.jpg")).base64digest, checksum
  end

  test "uploading from a large file in multiple parts" do
    @bucket.upload @key, file_fixture("starry_night.jpg").open

    checksum = Digest::SHA256.new.tap do |digest|
      @bucket.download(@key) do |io|
        io.each { |chunk| digest << chunk }
      end
    end.base64digest

    assert_equal Digest::SHA256.file(file_fixture("starry_night.jpg")).base64digest, checksum
  end
end
