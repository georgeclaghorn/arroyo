require "bundler/setup"
require "rake/testtask"

Rake::TestTask.new do |test|
  test.libs << "test"
  test.test_files = FileList["test/**/*_test.rb"].exclude("test/system/*")
  test.warning = false
end

Rake::TestTask.new("test:system") do |test|
  test.libs << "test"
  test.test_files = FileList["test/system/**/*_test.rb"]
  test.warning = false
end

task default: :test
