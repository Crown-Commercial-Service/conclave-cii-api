module Api
  module V1
    class SchemesController < ActionController::API
      def schemes
        scheme_register = SchemeRegister.select('scheme_register_code, scheme_name, scheme_uri, scheme_identifier, scheme_country_code').as_json(:except => :id)
        render json: scheme_register
      end
    end
  end
end
