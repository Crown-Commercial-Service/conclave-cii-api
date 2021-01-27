module Dnb
  class AdditionalIdentifier
    def initialize(registration_numbers)
      super()
      @company_number = nil
      @charity_number = nil
      @registration_numbers = registration_numbers
      @response_additional = []
    end

    def build_response
      search_additional_identifiers
      @response_additional
    end

    def search_additional_identifiers
      return if exists_or_null(@registration_numbers).blank?

      @registration_numbers.each do |api_rtn_params|
        companies_house(api_rtn_params['registrationNumber']) if api_rtn_params['typeDnBCode'] == Common::AdditionalIdentifier::DANDB_COMPANY_NUMBER_CODE
        find_that_charity_api(api_rtn_params['registrationNumber'], Common::AdditionalIdentifier::SCHEME_ENG_WALES_CHARITY) if api_rtn_params['typeDnBCode'].to_s == Common::AdditionalIdentifier::DANDB_ENG_WALES_CHARITY_NUMBER_CODE.to_s
      end
    end

    def companies_house(company_number)
      compnaies_house_results = CompaniesHouse::AdditionalIdentifier.new(company_number).build_response
      @response_additional.push(compnaies_house_results) if compnaies_house_results.present?
    rescue StandardError => e
      ApiLogging::Logger.warning(e)
    end

    def find_that_charity_api(charity_number, scheme)
      find_that_charity_results = FindThatCharity::AdditionalIdentifier.new(charity_number, scheme).build_response
      @response_additional.push(find_that_charity_results) if find_that_charity_results.present?
    rescue StandardError => e
      ApiLogging::Logger.warning(e)
    end

    def company_registeration_number
      company_registeration_additional_identifiers(@company_number)
    end

    def company_registeration_additional_identifiers(api_param)
      api_param.present? ? CompaniesHouse::AdditionalIdentifier.new(api_param).build_response : false
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    rescue StandardError => e
      ApiLogging::Logger.warning(e)
    end
  end
end
