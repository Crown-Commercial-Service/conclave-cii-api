module Api
  module V1
    class SchemesController < ActionController::API
      include Authorize::Token
      before_action :validate_api_key

      # rubocop:disable Style/HashSyntax
      # change scheme_register_code to just scheme.
      def schemes
        ccs_scheme = Common::AdditionalIdentifier::SCHEME_CCS
        scheme_register = SchemeRegister.select('scheme_register_code AS scheme, scheme_name, scheme_country_code').where.not(scheme_register_code: ccs_scheme).as_json(:except => :id)
        if scheme_register.blank?
          render json: '', status: :not_found
        else
          render json: scheme_register
        end
      end
      # rubocop:enable Style/HashSyntax
    end
  end
end
