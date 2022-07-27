module FindThatCharity
  class Search
    def initialize(charity_number, scheme_id)
      super()
      @charity_number = filter_charity_number(charity_number, scheme_id)
      @scheme_id = scheme_id
      @error = nil
      @result = []
      @additional_indentifers_list = []
    end

    def fetch_results
      conn = Common::ApiHelper.faraday_new(url: ENV.fetch('FINDTHATCHARITY_API_ENDPOINT', nil))
      resp = conn.get("/orgid/#{@scheme_id}-#{@charity_number}.json")
      logging(resp)
      @result = ActiveSupport::JSON.decode(resp.body) if resp.status == 200

      if resp.status == 200 && @result.key?('active') && @result['active'] == true
        build_response
      else
        false
      end
    end

    private

    def build_response
      {
        name: name,
        identifier: FindThatCharity::Identifier.new(@scheme_id, @result).build_response,
        additionalIdentifiers: filter_additional_indentifiers,
        address: FindThatCharity::Address.new(@result).build_response,
        contactPoint: FindThatCharity::Contact.new(@result).build_response
      }
    end

    def additional_identifiers
      additional_identifiers_linked_records if Common::ApiHelper.exists_or_null(@result['linked_records']).present?
    end

    def filter_additional_indentifiers
      additional_identifiers
      @additional_indentifers_list.uniq { |identifier| identifier[:id] }
    end

    def additional_identifiers_linked_records
      @additional_indentifers_list.concat(Common::AdditionalIdentifier.new.filter_find_that_charity_ids(@result['linked_records'], @charity_number))
    end

    def registration_numbers
      if Common::ApiHelper.exists_or_null(@result['companyNumber']).blank?
        []
      else
        search_companies_house
      end
    end

    def search_companies_house
      [CompaniesHouse::AdditionalIdentifier.new(@result['companyNumber']).build_response]
    end

    def name
      @result['name'] = @result['name'].present? ? @result['name'] : ''
    end

    def filter_charity_number(charity_number, scheme_id)
      charity_number = Common::ApiHelper.remove_nic(charity_number) if Common::AdditionalIdentifier::SCHEME_NORTHEN_IRELAND_CHARITY == scheme_id
      charity_number = Common::ApiHelper.add_sc(charity_number) if Common::AdditionalIdentifier::SCHEME_SCOTISH_CHARITY == scheme_id
      charity_number
    end

    def logging(resp)
      ApiLogging::Logger.api_status_error('Find that Charity | method:fetch_results', resp)
      ApiLogging::Logger.info(resp.headers['X-RateLimit-Remain'])
    end
  end
end
