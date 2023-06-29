module Ppon
  class Search
    def initialize(organisation_code, ccs_org_id)
      super()
      @organisation_code = organisation_code
      @ccs_org_id = ccs_org_id
    end

    def fetch_results
      build_response
    end

    def build_response
      {
        name: '',
        identifier: Ppon::Indentifier.new(@organisation_code, @ccs_org_id).build_response,
        additionalIdentifiers: [],
        address: Ppon::Address.new.build_response,
        contactPoint: Ppon::Contact.new.build_response
      }
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    rescue StandardError => e
      ApiLogging::Logger.info(e)
    end

    def logging(resp)
      ApiLogging::Logger.api_status_error('PPON API| method:fetch_results', resp)
      # ApiLogging::Logger.info(resp.headers['X-RateLimit-Remain'])
    end
  end
end
