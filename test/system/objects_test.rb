require "system_test_helper"

class Arroyo::ObjectsSystemTest < ActiveSupport::TestCase
  teardown { @bucket.delete "file.txt" }

  test "uploading from and downloading to a path on disk" do
    Tempfile.create([ "up", ".txt" ]) do |file|
      file.write "Hello world!"
      file.flush
      @bucket.upload "file.txt", file.path
    end

    Tempfile.create([ "down", ".txt" ]) do |file|
      @bucket.download "file.txt", file.path
      assert_equal "Hello world!", file.read
    end
  end

  test "uploading from and downloading to a file" do
    Tempfile.create([ "up", ".txt" ]) do |file|
      file.write "Hello world!"
      file.rewind
      @bucket.upload "file.txt", file
    end

    Tempfile.create([ "down", ".txt" ]) do |file|
      @bucket.download "file.txt", file

      file.rewind
      assert_equal "Hello world!", file.read
    end
  end

  test "checksumming" do
    Tempfile.create([ "up", ".txt" ]) do |file|
      file.write "Hello world!"
      file.rewind
      @bucket.upload "file.txt", file
    end

    checksum = Digest::SHA256.new.tap do |digest|
      @bucket.download("file.txt") do |io|
        io.each { |chunk| digest << chunk }
      end
    end.base64digest

    assert_equal Digest::SHA256.base64digest("Hello world!"), checksum
  end

  test "uploading and downloading binary data" do
    @bucket.upload "file.txt", file_fixture("daisy.jpg").open

    checksum = Digest::SHA256.new.tap do |digest|
      @bucket.download("file.txt") do |io|
        io.each { |chunk| digest << chunk }
      end
    end.base64digest

    assert_equal Digest::SHA256.file(file_fixture("daisy.jpg")).base64digest, checksum
  end

  test "uploading from a large file in multiple parts" do
    @bucket.upload "starry_night.jpg", file_fixture("starry_night.jpg").open

    checksum = Digest::SHA256.new.tap do |digest|
      @bucket.download("starry_night.jpg") do |io|
        io.each { |chunk| digest << chunk }
      end
    end.base64digest

    assert_equal Digest::SHA256.file(file_fixture("starry_night.jpg")).base64digest, checksum
  ensure
    @bucket.delete "starry_night.jpg"
  end
end
