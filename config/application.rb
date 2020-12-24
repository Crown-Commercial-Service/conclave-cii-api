require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CII
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    begin
      vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
      ENV['CCS_DEFAULT_DB_HOST'] = vcap_services['postgres'][0]['credentials']['host'].to_s
      ENV['CCS_DEFAULT_DB_PORT'] = vcap_services['postgres'][0]['credentials']['port'].to_s
      ENV['CCS_DEFAULT_DB_NAME'] = vcap_services['postgres'][0]['credentials']['name'].to_s
      ENV['CCS_DEFAULT_DB_USER'] = vcap_services['postgres'][0]['credentials']['username'].to_s
      ENV['CCS_DEFAULT_DB_PASSWORD'] = vcap_services['postgres'][0]['credentials']['password'].to_s
    rescue StandardError
      # Rails.logger.debug e
    end

    Rails.application.credentials.config.each do |key, value|
      next if key.to_s != ENV['SERVER_ENV_NAME'].to_s

      value.each do |env_key, env_value|
        ENV[env_key.to_s] = env_value.to_s
      end
    end


    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end
