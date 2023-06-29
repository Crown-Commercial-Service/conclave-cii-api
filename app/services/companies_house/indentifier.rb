module CompaniesHouse
  class Indentifier
    def initialize(result)
      super()
      @result = result
    end

    def build_response
      {
        scheme: 'GB-COH',
        id: id,
        legalName: legal_name,
        uri: ''
      }
    end

    def id
      exists_or_null(@result&.dig('company_number'))
    end

    def legal_name
      exists_or_null(@result&.dig('company_name'))
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
