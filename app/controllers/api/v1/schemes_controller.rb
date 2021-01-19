module Api
  module V1
    class SchemesController < ActionController::API
      include Authorize::Token
      before_action :validate_api_key

      # rubocop:disable Style/HashSyntax
      # change scheme_register_code to just scheme.
      def schemes
        scheme_register = SchemeRegister.select('scheme_register_code AS scheme, scheme_name, scheme_country_code').as_json(:except => :id)
        render json: scheme_register
      end
      # rubocop:enable Style/HashSyntax
    end
  end
end
