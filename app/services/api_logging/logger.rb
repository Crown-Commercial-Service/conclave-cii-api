module ApiLogging
  class Logger
    def self.warning(msg)
      Rails.logger.warn msg
    end
  end
end
