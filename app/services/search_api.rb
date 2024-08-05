class SearchApi
  attr_reader :result

  def initialize(organisation_id, scheme_id, ccs_org_id = nil, address_lookup: false, return_organisation_id: false)
    @organisation_id = Common::ApiHelper.remove_white_space_from_id(organisation_id)
    @scheme_id = scheme_id
    @ccs_org_id = ccs_org_id
    @result = []
    @return_organisation_id = return_organisation_id
    @addtional_identfiers = []
    @address_lookup = address_lookup
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def call
    case @scheme_id
    when Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE
      @result = get_companies_house(@organisation_id)
    when Common::AdditionalIdentifier::SCHEME_ENG_WALES_CHARITY, Common::AdditionalIdentifier::SCHEME_NORTHEN_IRELAND_CHARITY, Common::AdditionalIdentifier::SCHEME_SCOTISH_CHARITY
      @result =  get_charity(@organisation_id, @scheme_id)
    when Common::AdditionalIdentifier::SCHEME_DANDB
      @result =  get_duns(@organisation_id, @scheme_id)
    when Common::AdditionalIdentifier::SCHEME_NHS
      @result =  get_nhs(@organisation_id)
    when Common::AdditionalIdentifier::SCHEME_DFE
      @result =  get_dfe(@organisation_id)
    when Common::AdditionalIdentifier::SCHEME_PPON
      @result =  get_ppon(@organisation_id, @ccs_org_id)
    end

    @result if @result.present?
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  private

  def get_companies_house(company_reg_number)
    company_api = CompaniesHouse::Search.new(company_reg_number)
    results = company_api.fetch_results
    results[:additionalIdentifiers] = get_addtional_identfiers(results[:additionalIdentifiers]) if results.present?
    results
  end

  def get_charity(charity_number, scheme_id)
    find_that_charity = FindThatCharity::Search.new(charity_number, scheme_id)
    results = find_that_charity.fetch_results
    results[:additionalIdentifiers] = get_addtional_identfiers(results[:additionalIdentifiers]) if results.present?
    results
  end

  def get_duns(duns_number, scheme_id)
    spotlight = Spotlight::Search.new(duns_number, scheme_id)
    results = spotlight.fetch_results
    additional_identifiers = results[:additionalIdentifiers]
    results[:additionalIdentifiers] = []
    results[:additionalIdentifiers] = get_addtional_identfiers(additional_identifiers) if results.present? && additional_identifiers.any?
    results
  end

  def get_nhs(organisation_code)
    nhs = Nhs::Search.new(organisation_code)
    nhs.fetch_results
  end

  def get_dfe(organisation_code)
    dfe = Dfe::Search.new(organisation_code)
    dfe.fetch_results
  end

  def get_ppon(organisation_code, ccs_org_id)
    ppon = Ppon::Search.new(organisation_code, ccs_org_id)
    ppon.fetch_results
  end

  def get_addtional_identfiers(identfiers)
    return if @address_lookup

    identfiers.each do |identfier|
      identfier[:ccs_org_id] = @ccs_org_id unless @ccs_org_id.nil?
      validate_additional_identifiers(identfier)
      verify_addtional_identfiers(identfier)
    end
    @addtional_identfiers
  end

  def verify_addtional_identfiers(identfier)
    result = SearchApiAdditionalIdentifiers.new(identfier[:id], identfier[:scheme]).call
    @addtional_identfiers.push(result) unless result.nil?
  end

  def validate_additional_identifiers(identifier)
    validate = ApiValidations::Scheme.new(identifier, return_organisation_id: @return_organisation_id)
    errors.add(:identifier, validate.errors) unless validate.valid?
  end
end
