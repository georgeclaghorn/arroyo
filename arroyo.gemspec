Gem::Specification.new do |s|
  s.name     = "arroyo"
  s.version  = "0.1.0"
  s.authors  = "George Claghorn"
  s.email    = "georgeclaghorn@gmail.com"
  s.summary  = "A stream-oriented client for Amazon S3"
  s.homepage = "https://github.com/georgeclaghorn/arroyo"
  s.license  = "MIT"

  s.files      = Dir["README.md", "lib/**/*"]
  s.test_files = Dir["test/**/*"]

  s.required_ruby_version = ">= 2.6.0"

  s.add_dependency "activesupport", ">= 5.2.0"
  s.add_dependency "http", ">= 4.1.1"
  s.add_dependency "aws-sigv4", ">= 1.1.0"

  s.add_development_dependency "rake", ">= 12.3.2"
  s.add_development_dependency "webmock", ">= 3.7.3"
  s.add_development_dependency "byebug", ">= 11.0.1"
end
