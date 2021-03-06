source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.7'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'
# Use Puma as the app server
gem 'puma', '~> 4.3', '>= 4.3.8'
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
gem 'pg', '~> 0.18.4'
gem 'jwt'
gem 'faraday'
gem 'faraday_middleware'
gem 'graphlient'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
# For converting between cases for API request & response
gem 'olive_branch', '>= 3.0.0'
# test code complexity
gem 'flog'
gem 'vault'
# error logging
gem 'rollbar'
gem 'webmock', '>= 3.12.1'

group :development, :test do
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails', '>= 2.7.6'
  gem 'i18n-tasks', '>= 0.9.34'
  gem 'rspec-rails', '>= 5.0.1'
  gem 'rubocop', '>= 1.12.0'
  gem 'rubocop-performance', '>= 1.10.2'
  gem 'rubocop-rails', '>= 2.9.1'
  gem 'rubocop-rspec', '>= 2.2.0' # or gem 'rubocop-minitest'
  gem 'brakeman'
  gem 'pry-rails'
  gem 'factory_bot_rails', '>= 6.1.0'
  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
