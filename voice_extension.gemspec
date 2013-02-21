$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "voice_extension/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "voice_extension"
  s.version     = VoiceExtension::VERSION
  s.authors     = ["Anypresence"]
  s.email       = ["fake@fake.local"]
  s.homepage    = ""
  s.summary     = ""
  s.description = ""

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.11"
  s.add_dependency "json"
  s.add_dependency "multi_json"
  s.add_dependency "mongoid", "~> 3.0.6"
  s.add_dependency "liquid"
  s.add_dependency "local-env"
  s.add_dependency "faraday"
  s.add_dependency "twilio-ruby"

  s.add_development_dependency "factory_girl", "= 3.3.0"
  s.add_development_dependency "webmock"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "debugger"
  s.add_development_dependency "rspec"
  s.add_development_dependency "database_cleaner", '0.8.0'
end
