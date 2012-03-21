source 'https://rubygems.org'

gem 'rails', '3.2.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'twilio-ruby'
gem 'faraday'
gem "compass", :git => "git://github.com/chriseppstein/compass.git"
gem 'devise'
gem 'haml'
gem 'liquid'
gem 'hpricot'
gem 'dynamic_form'
gem "simple_form"
gem 'anypresence_extension', '0.0.1', :path => 'vendor/gems/anypresence_extension-0.0.1'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.0'
  gem 'coffee-rails', '~> 3.2.0'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

group :test, :development do
  gem 'local-env'
  gem 'pg'
  gem 'rspec-rails', '~> 2.5'
  gem 'ruby-debug19'
end

group :development do
  gem 'heroku-rails', :git => 'git://github.com/sid137/heroku-rails.git'
end

group :production do
  gem 'pg'
end

group :test do
  gem 'factory_girl'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'webmock'
  gem 'vcr'
end
