module ApiLogging
  class Logger
    def self.warning(msg)
      Rails.logger.warn msg
      Rollbar.warning msg
    end

    def self.info(info)
      Rails.logger.info info
      Rollbar.info info
    end

    def self.error(error)
      Rails.logger.error error
      Rollbar.error error
    end

    def self.fatal(msg)
      Rails.logger.fatal msg
      Rollbar.critical msg
    end

    def self.api_status_error(msg, resp)
      ApiLogging::Logger.fatal("#{msg} 403 ERROR #{resp.to_json}") if resp.status == 403
      ApiLogging::Logger.fatal("#{msg} 401 ERROR #{resp.to_json}") if resp.status == 401
      ApiLogging::Logger.fatal("#{msg} 429 ERROR Too Many Requests #{resp.to_json}") if resp.status == 429
    end

    def faraday_events
      # Subscribes to all events from Faraday::HttpCache.
      ActiveSupport::Notifications.subscribe 'http_cache.faraday' do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        cache_status = event.payload[:cache_status]
        puts cache_status
        case cache_status
        when :fresh, :valid
          puts 'api-calls.cache_hits'
        when :invalid, :miss
          puts 'api-calls.cache_misses'
        when :unacceptable
          puts 'api-calls.cache_bypass'
        end
      end
    end
  end
end
