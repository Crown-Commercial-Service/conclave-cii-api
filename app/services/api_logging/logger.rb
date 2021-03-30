module ApiLogging
  class Logger
    def self.warning(msg)
      Rails.logger.warn msg
    end

    def self.info(info)
      Rails.logger.info info
    end

    def self.error(error)
      Rails.logger.error error
    end
  end
end
