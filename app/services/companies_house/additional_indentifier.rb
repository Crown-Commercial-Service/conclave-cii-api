module CompaniesHouse
  class AdditionalIndentifier
    def initialize(company_number)
      super()
      @company_number = company_number
      @search_result = []
    end

    def build_response
      @search_result = @company_number.present? ? compnaies_house_api : ''
      return if @search_result.include?('name')

      {
        'scheme': 'GB-COH',
        'id': company_number,
        'legalName': legal_name,
        'uri': uri,
      }
    end

    def company_number
      exists_or_null(@company_number)
    end

    def legal_name
      exists_or_null(@search_result[:name])
    end

    def uri
      exists_or_null(@search_result[:Identifier][:uri])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end

    def compnaies_house_api
      company_api = CompaniesHouse::Search.new(@company_number)
      company_api.fetch_results
    end
  end
end
