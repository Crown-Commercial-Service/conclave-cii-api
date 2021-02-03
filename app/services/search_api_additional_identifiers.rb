class SearchApiAdditionalIdentifiers
  attr_reader :result

  def initialize(organisation_id, scheme_id)
    @organisation_id = organisation_id
    @scheme_id = scheme_id
    @result = []
  end

  def call
    case @scheme_id
    when Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE
      @result = get_companies_house_additional(@organisation_id)
    when Common::AdditionalIdentifier::SCHEME_ENG_WALES_CHARITY, Common::AdditionalIdentifier::SCHEME_NORTHEN_IRELAND_CHARITY, Common::AdditionalIdentifier::SCHEME_SCOTISH_CHARITY
      @result = get_charity_additional(@organisation_id, @scheme_id)
    end

    @result if @result.present?
  end

  private

  def get_companies_house_additional(company_reg_number)
    CompaniesHouse::AdditionalIdentifier.new(company_reg_number).build_response
  end

  def get_charity_additional(chartity_number, scheme_id)
    FindThatCharity::AdditionalIdentifier.new(chartity_number, scheme_id).build_response
  end
end
