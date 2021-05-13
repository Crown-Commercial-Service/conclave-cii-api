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
    end
  end
end
