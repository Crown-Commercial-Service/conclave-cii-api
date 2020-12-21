class SearchApi
  def initialize(organisation_id, scheme_id)
    @organisation_id = organisation_id
    @scheme_id = scheme_id
    @result = []
  end

  def call
    case @scheme_id
    when 'GB-COH'
      @result = get_companies_house(@organisation_id)
    when 'GB-CHC'
      @result =  get_charity(@organisation_id, @scheme_id)
    when 'US-DUN'
      @result =  get_duns(@organisation_id)
    when 'GB-NIC'
      @result =  get_charity(@organisation_id, @scheme_id)
    when 'GB-SC'
      @result =  get_charity(@organisation_id, @scheme_id)
    end

    @result if @result.present?
  end

  attr_reader :result

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

  def get_charity_base(chartity_number)
    find_that_charity = Charitybase::Search.new(chartity_number)
    find_that_charity.fetch_results
  end
end
