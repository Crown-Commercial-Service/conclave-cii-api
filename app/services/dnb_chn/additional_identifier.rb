module DnbChn
  class AdditionalIdentifier
    def initialize(company_number)
      super()
      @company_number = company_number
      @search_result = []
    end

    def build_response
      @search_result = @company_number.present? ? search_duns_api : false
      response_payload if @search_result
    end

    def response_payload
      {
        scheme: 'US-DUN',
        id: company_number,
        legalName: legal_name,
        uri: uri,
      }
    end

    def company_number
      Common::ApiHelper.exists_or_null(@search_result[:identifier][:id])
    end

    def legal_name
      Common::ApiHelper.exists_or_null(@search_result[:name])
    end

    def uri
      Common::ApiHelper.exists_or_null(@search_result[:identifier][:uri])
    end

    private

    def search_duns_api
      duns_api = DnbChn::Search.new(@company_number, true)
      duns_api.fetch_results
    end
  end
end
