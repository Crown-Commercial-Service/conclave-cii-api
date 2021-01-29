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
    find_that_charity.fetch_results
  end

  def get_duns(dnd_number)
    dnb = Dnb::Search.new(dnd_number)
    dnb.fetch_results
  end
end
