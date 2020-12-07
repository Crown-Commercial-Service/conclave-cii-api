module Api
  module V1
    class IdentitiesSchemesOrganisationsController < ActionController::API
      def organisations
        @reg_number =  params[:orginasation_id]
        @scheme_id  =  params[:scheme_id]
        @result = []

        error_payload = {
          error: 'No such scheme registered',
          status: :not_found
        }

        case @scheme_id
        when 'GB-COH'
          @result = get_companies_house(@reg_number)
        when 'GB-CHC'
          @result =  get_charity(@reg_number)
        when 'US-DUN'
          @result =  get_duns(@reg_number)
        end

        if @result.empty?
          render json: error_payload, status: :not_found
        else
          render json: @result
        end
      end

      def get_companies_house(company_reg_number)
        company_api = CompaniesHouse::Search.new(company_reg_number)
        company_api.fetch_results
      end

      def get_charity(chartity_number)
        find_that_charity = FindThatCharity::Search.new(chartity_number)
        find_that_charity.fetch_results
      end

      def get_duns(dnd_number)
        dnb = Dnb::Search.new(dnd_number)
        dnb.fetch_results
      end
    end
  end
end
