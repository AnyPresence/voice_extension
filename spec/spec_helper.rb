# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../spec/dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'database_cleaner'
require 'voice_extension'
require 'shoulda/matchers'
require 'factory_girl'

FactoryGirl.find_definitions

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[Rails.root.join("spec/lib/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
    
  config.before(:suite) do
    DatabaseCleaner[:mongoid].clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner[:mongoid].clean
  end

  config.after(:each) do
    DatabaseCleaner[:mongoid].clean
  end
end