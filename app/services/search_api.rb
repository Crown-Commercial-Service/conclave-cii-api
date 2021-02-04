class SearchApi
  attr_reader :result

  def initialize(organisation_id, scheme_id)
    @organisation_id = organisation_id
    @scheme_id = scheme_id
    @result = []
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
    company_api.fetch_results
  end

  def get_charity(chartity_number, scheme_id)
    find_that_charity = FindThatCharity::Search.new(chartity_number, scheme_id)
    results = find_that_charity.fetch_results
    results[:additionalIdentifiers] = get_addtional_identfiers(results[:additionalIdentifiers]) if results.present?
    results
  end

  def get_duns(dnd_number)
    dnb = Dnb::Search.new(dnd_number)
    results = dnb.fetch_results
    results[:additionalIdentifiers] = get_addtional_identfiers(results[:additionalIdentifiers]) if results.present?
    results
  end

  def get_addtional_identfiers(identfiers)
    addtional_identfiers = []
    identfiers.each do |identfier|
      result = SearchApiAdditionalIdentifiers.new(identfier[:id], identfier[:scheme]).call
      addtional_identfiers.push(result) unless result.nil?
    end
    addtional_identfiers
  end
end
