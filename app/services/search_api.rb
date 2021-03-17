class SearchApi
  attr_reader :result

  def initialize(organisation_id, scheme_id, ccs_org_id = nil)
    @organisation_id = Common::ApiHelper.remove_white_space_from_id(organisation_id)
    @scheme_id = scheme_id
    @ccs_org_id = ccs_org_id
    @result = []
    @addtional_identfiers = []
  end

  def call
    case @scheme_id
    when Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE
      @result = get_companies_house(@organisation_id)
    when Common::AdditionalIdentifier::SCHEME_ENG_WALES_CHARITY, Common::AdditionalIdentifier::SCHEME_NORTHEN_IRELAND_CHARITY, Common::AdditionalIdentifier::SCHEME_SCOTISH_CHARITY
      @result =  get_charity(@organisation_id, @scheme_id)
    when Common::AdditionalIdentifier::SCHEME_DANDB
      @result =  get_duns(@organisation_id)
    end

    @result if @result.present?
  end

  private

  def get_companies_house(company_reg_number)
    company_api = CompaniesHouse::Search.new(company_reg_number)
    results = company_api.fetch_results
    Salesforce::AdditionalIdentifier.new(results).build_response if results.present?
  end

  def get_charity(charity_number, scheme_id)
    find_that_charity = FindThatCharity::Search.new(charity_number, scheme_id)
    results = find_that_charity.fetch_results
    results[:additionalIdentifiers] = get_addtional_identfiers(results[:additionalIdentifiers]) if results.present?
    Salesforce::AdditionalIdentifier.new(results).build_response if results.present?
  end

  def get_duns(dnd_number)
    dnb = Dnb::Search.new(dnd_number)
    results = dnb.fetch_results
    results[:additionalIdentifiers] = get_addtional_identfiers(results[:additionalIdentifiers]) if results.present?
    Salesforce::AdditionalIdentifier.new(results).build_response if results.present?
  end

  def get_addtional_identfiers(identfiers)
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
    validate = ApiValidations::Scheme.new(identifier)
    errors.add(:identifier, validate.errors) unless validate.valid?
  end
end
