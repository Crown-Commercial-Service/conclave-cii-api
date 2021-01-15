module ApiLogging
  class Logger
    def self.warning(msg)
      Rails.logger.warn msg
      # Rollbar.log('error', e) unless Rails.env.production?
    end
  end
end
