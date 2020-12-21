module Api
  module V1
    class SchemesController < ActionController::API
      def schemes
        scheme_register = SchemeRegister.all
        render json: scheme_register
      end
    end
  end
end
