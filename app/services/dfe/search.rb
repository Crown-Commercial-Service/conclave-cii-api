module Dfe
  class Search
    require 'faraday'
    require 'uri'

    def initialize(organisation_code, additional_identifier_search: false)
      super()
      @organisation_code = organisation_code
      @company_number = nil
      @error = nil
      @result = []
      @additional_indentifers_list = []
      @additional_identifier_search = additional_identifier_search != false
    end

    def dfe_results
      conn = Common::ApiHelper.faraday_new(url: ENV.fetch('DFE_URL', nil))
      resp = conn.get("#{ENV.fetch('DFE_URL', nil)}/establishment/#{@organisation_code}?subscription-key=true") do |req|
        req.headers['Authorization'] = "Bearer #{ENV.fetch('DFE_ACCESS_TOKEN', nil)}"
        req.headers['Ocp-Apim-Subscription-Key'] = ENV.fetch('DFE_SUBSCRIPTION_KEY', nil)
      end
      logging(resp)

      ApiValidations::ApiErrorValidationResponse.new(resp.status) if @additional_identifier_search == false
      resp
    end

    def fetch_results
      post_access_token unless access_token_check
      resp = dfe_results
      @result = ActiveSupport::JSON.decode(resp.body) if resp.status == 200

      if resp.status == 200 && @result.key?('EstablishmentStatus') && @result['EstablishmentStatus']['Name'] == 'Open'
        build_response
      else
        false
      end
    end

    def post_access_token
      response = Faraday.post("#{ENV.fetch('DFE_AUTH_URL', nil)}/oauth2/v2.0/token") do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = URI.encode_www_form(data)
      end

      ENV['DFE_ACCESS_TOKEN'] = JSON.parse(response.body)['access_token']
    end

    def data
      {
        grant_type: 'client_credentials',
        client_id: ENV.fetch('DFE_AUTH_CLIENT_ID', nil),
        client_secret: ENV.fetch('DFE_AUTH_CLIENT_SECRET', nil),
        scope: ENV.fetch('DFE_AUTH_SCOPE', nil)
      }
    end

    def access_token_check
      return false if ENV['DFE_ACCESS_TOKEN'].blank?

      decoded_token = (JWT.decode ENV.fetch('DFE_ACCESS_TOKEN', nil), nil, false)[0]

      return true if decoded_token['exp'] > Time.now.to_i

      false
    end

    def build_response
      {
        name: name,
        identifier: Dfe::Indentifier.new(@result).build_response,
        additionalIdentifiers: [],
        address: Dfe::Address.new(@result).build_response,
        contactPoint: Dfe::Contact.new(@result).build_response
      }
    end

    def name
      exists_or_null(@result['Establishment']['Name'])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    rescue StandardError => e
      ApiLogging::Logger.info(e)
    end

    def logging(resp)
      ApiLogging::Logger.api_status_error('DFE API| method:fetch_results', resp)
    end
  end
end
