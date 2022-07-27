module SecurityService
  class Auth
    def initialize(client_id, access_token)
      @client_id = client_id
      @access_token = access_token
    end

    def sec_api_validate_token
      url = "/security/tokens/validation?client-id=#{@client_id}"
      conn = Faraday.new(url: ENV.fetch('SECURITY_SERVICE_URL', nil))
      conn.authorization :Bearer, @access_token
      resp = conn.post(url, '', { 'Content-Type' => 'application/x-www-form-urlencoded' })
      ApiLogging::Logger.api_status_error('Security Token Validation | method:sec_api_validate_token', resp)
      if resp.status == 200
        true if resp.body == 'true'
      else
        false
      end
    end
  end
end
