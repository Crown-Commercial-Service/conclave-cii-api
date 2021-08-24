module CompaniesHouse
  class Search
    def initialize(company_reg_number)
      super()
      @company_reg_number = company_reg_number
      @error = nil
      @result = []
      @additional_indentifers_list = []
    end

    def fetch_results
      # conn = Faraday.new(url: ENV['COMPANIES_HOUSE_API_ENDPOINT'])

      conn = Faraday.new(url: ENV['COMPANIES_HOUSE_API_ENDPOINT']) do |builder|
        builder.use Faraday::HttpCache, store: Rails.cache, logger: Rails.logger, shared_cache: false
        builder.use Faraday::OverrideCacheControl, cache_control: 'public, max-age=3600'
        builder.adapter Faraday.default_adapter
      end

      conn.basic_auth("#{ENV['COMPANIES_HOUSE_API_TOKEN']}:", '')
      resp = conn.get("/company/#{@company_reg_number}")
      ApiLogging::Logger.api_status_error('Companies House API | method:fetch_results', resp)
      @result = ActiveSupport::JSON.decode(resp.body) if resp.status == 200
      ApiLogging::Logger.info(resp.headers['X-RateLimit-Remain'])
      ApiLogging::Logger.info(resp.inspect)
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
        additionalIdentifiers: [],
        address: CompaniesHouse::Address.new(@result).build_response,
        contactPoint: CompaniesHouse::Contact.new(@result).build_response
      }
    end

    def name
      @result['company_name']
    end
  end
end
