module Common
  class ApiHelper
    def self.exists_or_null(api_param)
      api_param.present? ? api_param : ''
    rescue StandardError => e
      ApiLogging::Logger.warning(e)
    end

    # Remove NIC|NI from Northen Ireland Charities as the api
    # Find that charity end points do not support NIC in the
    # charity number
    def self.remove_nic(charity_number)
      charity_number.sub(/(NIC|NI)/, '')
    end

    # Add SC if Scottish Charity
    # api client require all scottish charities
    # to proceeding with SC before number.
    def self.add_sc(charity_number)
      charity_number = "SC#{charity_number}" unless charity_number.include? 'SC'
      charity_number
    end
  end
end
