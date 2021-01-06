module Dnb
  class AdditionalIdentifier
    def initialize(company_number)
      super()
      @company_number = company_number
    end

    def build_response
      if company_registeration_number.blank?
        []
      else
        [additional_identifiers]
      end
    end

    def additional_identifiers
      CompaniesHouse::AdditionalIdentifier.new(@company_number).build_response
    end

    def company_registeration_number
      company_registeration_additional_identifiers(@company_number)
    end

    def company_registeration_additional_identifiers(api_param)
      api_param.present? ? CompaniesHouse::AdditionalIdentifier.new(api_param).build_response : false
    end
  end
end
