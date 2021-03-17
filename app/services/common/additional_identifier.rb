module Common
  class AdditionalIdentifier
    DANDB_COMPANY_NUMBER_CODE = 2541
    DANDB_ENG_WALES_CHARITY_NUMBER_CODE = 33463
    DANDB_SCOTTISH_CHARITY_NUMBER_CODE = 33461
    DANDB_NORTHERN_IRELAND_CHARITY_NUMBER_CODE = 33462
    SCHEME_ENG_WALES_CHARITY = 'GB-CHC'.freeze
    SCHEME_NORTHEN_IRELAND_CHARITY = 'GB-NIC'.freeze
    SCHEME_SCOTISH_CHARITY = 'GB-SC'.freeze
    SCHEME_COMPANIES_HOUSE = 'GB-COH'.freeze
    SCHEME_DANDB = 'US-DUN'.freeze
    SCHEME_CCS = 'GB-CCS'.freeze

    # The below three constants are required to match the correct uri provided in the identifiers uri property.
    # If you change any of these variable names, it must also be updated in identifier.rb, in the module 'FindThatCharity'.
    GB_CHC_SCHEME_URI_SITE = 'Charity Commission England and Wales'.freeze
    GB_NIC_SCHEME_URI_SITE = 'Charity Commission Northern Ireland'.freeze
    GB_SC_SCHEME_URI_SITE = 'Office of Scottish Charity Regulator'.freeze

    def schemes
      [SCHEME_ENG_WALES_CHARITY, SCHEME_NORTHEN_IRELAND_CHARITY, SCHEME_SCOTISH_CHARITY, SCHEME_COMPANIES_HOUSE, SCHEME_DANDB]
    end

    def dandb_codes
      [DANDB_COMPANY_NUMBER_CODE, DANDB_ENG_WALES_CHARITY_NUMBER_CODE, DANDB_SCOTTISH_CHARITY_NUMBER_CODE, DANDB_NORTHERN_IRELAND_CHARITY_NUMBER_CODE]
    end

    def dandb_scheme(dandb_code)
      case dandb_code
      when DANDB_COMPANY_NUMBER_CODE
        SCHEME_COMPANIES_HOUSE
      when DANDB_ENG_WALES_CHARITY_NUMBER_CODE
        SCHEME_ENG_WALES_CHARITY
      when DANDB_SCOTTISH_CHARITY_NUMBER_CODE
        SCHEME_SCOTISH_CHARITY
      when DANDB_NORTHERN_IRELAND_CHARITY_NUMBER_CODE
        SCHEME_NORTHEN_IRELAND_CHARITY
      end
    end

    def filter_find_that_charity_ids(linked_records, charity_number)
      result = []
      linked_records.each do |linked_record|
        linked_id = linked_record['orgid'].split('-')
        scheme = "#{linked_id[0]}-#{linked_id[1]}"
        next unless charity_number != linked_id[2] && schemes.include?(scheme)

        identifier = {}
        identifier[:scheme] = "#{linked_id[0]}-#{linked_id[1]}"
        identifier[:id] = linked_id[2]
        result.push(identifier)
      end
      result
    end

    def filter_dandb_ids(registration_numbers, duns_number)
      result = []
      registration_numbers.each do |registration_number|
        next unless duns_number != registration_number['registrationNumber'] && dandb_codes.include?(registration_number['typeDnBCode'])

        identifier = {}
        identifier[:scheme] = dandb_scheme(registration_number['typeDnBCode'])
        identifier[:id] = registration_number['registrationNumber']
        result.push(identifier)
      end
      result
    end

    def return_uri(searched_scheme)
      case searched_scheme.to_s
      when 'GB-CHC'
        GB_CHC_SCHEME_URI_SITE
      when 'GB-SC'
        GB_SC_SCHEME_URI_SITE
      when 'GB-NIC'
        GB_NIC_SCHEME_URI_SITE
      else
        ''
      end
    end
  end
end
