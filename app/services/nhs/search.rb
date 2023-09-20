module Nhs
  class Search
    def initialize(organisation_code, additional_identifier_search = false)
      super()
      @organisation_code = organisation_code
      @company_number = nil
      @error = nil
      @result = []
      @additional_indentifers_list = []
      @additional_identifier_search = additional_identifier_search != false
    end

    def fetch_results
      fetch_results_from_api
    rescue StandardError => e
      ApiLogging::Logger.fatal("NHS API| method:fetch_results, #{e.to_json}")
      ApiValidations::ApiErrorValidationResponse.new(503) if @additional_identifier_search == false
    end

    def fetch_results_from_api
      conn = Common::ApiHelper.faraday_new(url: 'https://directory.spineservices.nhs.uk')
      resp = conn.get("/ORD/2-0-0/organisations/#{@organisation_code}")
      logging(resp)
      @result = ActiveSupport::JSON.decode(resp.body) if resp.status == 200

      if resp.status == 200 && @result.key?('Organisation') && @result['Organisation']['Status'] == 'Active'
        build_response
      else
        false
      end
    end

    def build_response
      {
        name: name,
        identifier: Nhs::Indentifier.new(@result).build_response,
        additionalIdentifiers: [],
        address: Nhs::Address.new(@result).build_response,
        contactPoint: Nhs::Contact.new(@result).build_response
      }
    end

    def name
      exists_or_null(@result['Organisation']['Name'])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    rescue StandardError => e
      ApiLogging::Logger.info(e)
    end

    def logging(resp)
      ApiLogging::Logger.api_status_error('NHS API| method:fetch_results', resp)
      # ApiLogging::Logger.info(resp.headers['X-RateLimit-Remain'])
    end
  end
end
