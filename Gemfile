source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.1.3'
# Use sqlite3 as the database for Active Record. When using Alpine, needs to be compiled from source using the musl C compiler.
gem 'sqlite3', '~> 1.6', git: 'https://github.com/sparklemotion/sqlite3-ruby.git', tag: 'v1.6.5'
# Use Puma as the app server
gem 'puma', '~> 6.0', '>= 6.0.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false
# for postgresql
gem 'activerecord-postgis-adapter', '>= 6.0.1'
gem 'pg'
gem 'jwt'
gem 'faraday'
gem 'faraday_middleware'
gem 'faraday-http-cache'
gem 'graphlient'
# Redis gems
gem 'redis'
gem 'redis-namespace'
gem 'redis-rails', '>= 5.0.2'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
# For converting between cases for API request & response
gem 'olive_branch', '>= 4.0.1'
# test code complexity
gem 'flog'
# gem 'vault'
# error logging
gem 'rollbar'
gem 'webmock', '>= 3.20.0'
# aws ssm
gem 'aws-sdk-ssm'

group :development, :test do
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails', '>= 2.7.6'
  gem 'i18n-tasks', '>= 1.0.14'
  gem 'rspec-rails', '>= 6.0.4'
  gem 'rubocop', '>= 1.56.4'
  gem 'rubocop-performance', '>= 1.19.1'
  gem 'rubocop-rails', '>= 2.21.2'
  gem 'rubocop-rspec', '>= 2.24.1' # or gem 'rubocop-minitest'
  gem 'brakeman'
  gem 'pry-rails'
  gem 'factory_bot_rails', '>= 6.4.3'
  gem 'simplecov', require: false
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby ruby]
