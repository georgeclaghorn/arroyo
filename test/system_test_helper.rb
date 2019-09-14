require "test_helper"

WebMock.disable!

CLIENT = Arroyo::Client.new \
  access_key_id:     ENV.fetch("S3_ACCESS_KEY_ID"),
  secret_access_key: ENV.fetch("S3_SECRET_ACCESS_KEY"),
  region:            ENV.fetch("S3_REGION")

BUCKET = CLIENT.buckets.open(ENV.fetch("S3_BUCKET"))

class ActiveSupport::TestCase
  setup do
    @client = CLIENT
    @bucket = BUCKET
  end
end
