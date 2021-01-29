module Common
  class ApiHelper
    def self.exists_or_null(api_param)
      api_param.present? ? api_param : ''
    rescue StandardError => e
      ApiLogging::Logger.warning(e)
    end

    # Remove NIC from Northen Ireland Charities as the api
    # Fint that charity end points donot support NIC in the
    # number string
    def self.remove_nic(charity_number)
      charity_number.sub('NI', '')
    end
  end
end
