module Common
  class ApiHelper
    def self.exists_or_null(api_param)
      api_param.present? ? api_param : ''
    rescue StandardError => e
      ApiLogging::Logger.warning(e)
    end

    # Remove NIC|NI from Northen Ireland Charities as the api
    # Find that charity end points do not support NIC in the
    # charity number
    def self.remove_nic(charity_number)
      charity_number.sub(/(NIC|NI)/, '')
    end

    # Add SC if Scottish Charity
    # api client require all scottish charities
    # to proceeding with SC before number.
    def self.add_sc(charity_number)
      charity_number = "SC#{charity_number}" unless charity_number.include? 'SC'
      charity_number
    end

    # Add NIC if Northern ireland Charity
    def self.add_nic(charity_number)
      charity_number = "NIC#{charity_number}" unless charity_number.include? 'NIC'
      charity_number
    end

    def self.filter_charity_number(charity_number, scheme_id)
      charity_number = Common::ApiHelper.add_nic(charity_number) if Common::AdditionalIdentifier::SCHEME_NORTHEN_IRELAND_CHARITY == scheme_id
      charity_number = Common::ApiHelper.add_sc(charity_number) if Common::AdditionalIdentifier::SCHEME_SCOTISH_CHARITY == scheme_id
      charity_number
    end

    def self.filter_sc(charity_number, scheme_id)
      charity_number = Common::ApiHelper.add_sc(charity_number) if Common::AdditionalIdentifier::SCHEME_SCOTISH_CHARITY == scheme_id
      charity_number
    end

    def self.clean_charity_number(charity_number, scheme_id)
      charity_number = Common::ApiHelper.remove_nic(charity_number) if Common::AdditionalIdentifier::SCHEME_NORTHEN_IRELAND_CHARITY == scheme_id
      Common::ApiHelper.filter_sc(charity_number, scheme_id)
    end

    def self.remove_white_space_from_id(id)
      id.to_s.gsub(/\s+/, '')
    end

    def self.hide_all_ccs_schemes(scheme_id, status)
      scheme_id == Common::AdditionalIdentifier::SCHEME_CCS ? true : status
    end

    def self.bearer_token(request)
      pattern = /^Bearer /
      header  = request['Authorization']
      header.gsub(pattern, '') if header&.match(pattern)
    end

    def self.decode_token(request)
      bearer_token_from_header = Common::ApiHelper.bearer_token(request)
      JWT.decode bearer_token_from_header, nil, false if bearer_token_from_header.present?
    rescue StandardError
      {}
    end

    def self.find_client(api_key_string)
      client = Client.find_by(api_key: api_key_string.to_s)
      client.id
    end

    # Returns a random 4 digit number, to concatonate onto a dummy id. (Part of work for Nick Fine).
    def self.generate_random_id_end
      rand(1000..9998).to_i
    end

    # Returns true or false, depending on if the dummy org is found or not. (Part of work for Nick Fine).
    def self.find_mock_duns_org(scheme, id)
      if id.to_s == Common::AdditionalIdentifier::MOCK_DANDB_ID && scheme.to_s == Common::AdditionalIdentifier::SCHEME_DANDB
        true
      else
        id.to_s == Common::AdditionalIdentifier::MOCK_SF_ID && scheme.to_s == Common::AdditionalIdentifier::SCHEME_CCS
      end
    end

    # Creates and adds the dummy org, and returns the created ccs_ord_id. (Part of work for Nick Fine).
    def self.add_dummy_org(api_key_to_string)
      organisation = OrganisationSchemeIdentifier.new
      organisation.scheme_code = Common::AdditionalIdentifier::SCHEME_DANDB
      organisation.scheme_org_reg_number = "11111#{Common::ApiHelper.generate_random_id_end}"
      organisation.uri = 'test.com'
      organisation.legal_name = 'Nicks Testing Organisation'
      organisation.organisationId = Common::GenerateId.organisationId
      organisation.primary_scheme = true
      organisation.hidden = false
      organisation.client_id = Common::ApiHelper.find_client(api_key_to_string)
      organisation.save
      organisation.organisationId
    end

    def self.return_mock_duns
      {
        name: 'Nicks Testing Organisation',
        identifier: {
          scheme: Common::AdditionalIdentifier::SCHEME_DANDB,
          id: Common::AdditionalIdentifier::MOCK_DANDB_ID,
          legalName: 'Nicks Testing Organisation',
          uri: ''
        },
        additionalIdentifiers: [],
        address: {
          streetAddress: 'Testing',
          locality: 'Testing',
          region: 'Testing',
          postalCode: 'AB12 3CD',
          countryName: 'England'
        },
        contactPoint: {
          name: '',
          email: '',
          telephone: '01234567890',
          faxNumber: '',
          uri: ''
        }
      }
    end

    def self.return_all_organisation_schemes(organisationId)
      Common::RegisteredOrganisationResponse.new(organisationId, hidden: true).response_payload
    end

    def self.faraday_new(options)
      Faraday.new(options) do |builder|
        builder.use Faraday::HttpCache, store: Rails.cache, logger: Rails.logger, shared_cache: false
        builder.use Faraday::OverrideCacheControl, cache_control: 'public, max-age=86400'
        builder.adapter Faraday.default_adapter
      end
    end
  end
end
