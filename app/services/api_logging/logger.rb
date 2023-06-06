module ApiLogging
  class Logger
    def self.warning(msg)
      Rails.logger.warn msg
      Rollbar.warning msg if msg.present?
    end

    def self.info(info)
      Rails.logger.info info
      Rollbar.info info if info.present?
    end

    def self.error(error)
      Rails.logger.error error
      Rollbar.error error if error.present?
    end

    def self.fatal(msg)
      Rails.logger.fatal msg
      Rollbar.critical msg if msg.present?
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
        ApiLogging::Logger.info(cache_status)
        case cache_status
        when :fresh, :valid
          ApiLogging::Logger.info('api-calls.cache_hits')
        when :invalid, :miss
          ApiLogging::Logger.info('api-calls.cache_misses')
        when :unacceptable
          ApiLogging::Logger.info('api-calls.cache_bypass')
        end
      end
    end
  end
end
