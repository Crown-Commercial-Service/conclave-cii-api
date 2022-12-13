module Dfe
  class Search
    require 'faraday'
    require 'uri'

    def initialize(organisation_code)
      super()
      @organisation_code = organisation_code
      @company_number = nil
      @error = nil
      @result = []
      @additional_indentifers_list = []
    end

    def fetch_results
      post_access_token unless access_token_check
      resp = Faraday.get("#{ENV['DFE_URL']}/establishment/#{@organisation_code}?subscription-key=true") do |req|
        req.headers['Authorization'] = "Bearer #{ENV['DFE_ACCESS_TOKEN']}"
        req.headers['Ocp-Apim-Subscription-Key'] = ENV['DFE_SUBSCRIPTION_KEY']
      end
      logging(resp)
      @result = ActiveSupport::JSON.decode(resp.body) if resp.status == 200

      if resp.status == 200 && @result.key?('EstablishmentStatus') && @result['EstablishmentStatus']['Name'] == 'Open'
        build_response
      else
        false
      end
    end

    def post_access_token
      response = Faraday.post("#{ENV['DFE_AUTH_URL']}/oauth2/v2.0/token") do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = URI.encode_www_form(data)
      end

      return ENV['DFE_ACCESS_TOKEN'] = JSON.parse(response.body)["access_token"]
    end

    def data
      {
        :grant_type => "client_credentials",
        :client_id => ENV['DFE_AUTH_CLIENT_ID'],
        :client_secret => ENV['DFE_AUTH_CLIENT_SECRET'],
        :scope => ENV['DFE_AUTH_SCOPE']
      }
    end

    def access_token_check
      return false if ENV['DFE_ACCESS_TOKEN'].blank?
      
      decoded_token = (JWT.decode ENV['DFE_ACCESS_TOKEN'], nil, false)[0]

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
