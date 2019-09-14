require "bundler/setup"

require "active_support"
require "active_support/test_case"
require "active_support/testing/autorun"

require "webmock/minitest"
require "byebug"

require "arroyo"

class ActiveSupport::TestCase
  def file_fixture(path)
    Pathname.new File.expand_path("fixtures/files/#{path}", __dir__)
  end
end
