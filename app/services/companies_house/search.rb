module CompaniesHouse
  class Search
    def initialize(company_reg_number, additional_identifier_search = false)
      super()
      @company_reg_number = company_reg_number
      @error = nil
      @result = []
      @additional_indentifers_list = []
      @additional_identifier_search = additional_identifier_search != false
    end

    def fetch_results
      fetch_results_from_api
    rescue StandardError => e
      ApiLogging::Logger.fatal("Companies House API | method:fetch_results, #{e.to_json}")
      ApiValidations::ApiErrorValidationResponse.new(503) if @additional_identifier_search == false
    end

    def fetch_results_from_api
      conn = Common::ApiHelper.faraday_new(url: ENV.fetch('COMPANIES_HOUSE_API_ENDPOINT', nil))
      conn.basic_auth("#{ENV.fetch('COMPANIES_HOUSE_API_TOKEN', nil)}:", '')
      resp = conn.get("/company/#{@company_reg_number}")
      logging(resp)
      ApiValidations::ApiErrorValidationResponse.new(resp.status) if @additional_identifier_search == false
      @result = ActiveSupport::JSON.decode(resp.body) if resp.status == 200

      if resp.status == 200 && @result.key?('company_status') && @result['company_status'] == 'active'
        build_response
      else
        false
      end
    end

    private

    def build_response
      {
        name: name,
        identifier: CompaniesHouse::Indentifier.new(@result).build_response,
        additionalIdentifiers: additional_identifier_duns,
        address: CompaniesHouse::Address.new(@result).build_response,
        contactPoint: CompaniesHouse::Contact.new(@result).build_response
      }
    end

    def name
      @result['company_name']
    end

    def additional_identifier_duns
      # Comment this out while we are unable to search Spotlight by Companies Number. (This is a requested feature, so will soon be needed).
      # By setting duns_search as equal to nil, the lower conditional will handle the rest, as required.
      duns_search = nil # Spotlight::AdditionalIdentifier.new(@company_reg_number, Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE).build_response

      if duns_search.present?
        [duns_search]
      else
        []
      end
    end

    def logging(resp)
      ApiLogging::Logger.api_status_error('Companies House API | method:fetch_results', resp)
      # ApiLogging::Logger.info("Companies House API | Rate Limit remaining: #{resp.headers['x-ratelimit-remain']}")
    end
  end
end
