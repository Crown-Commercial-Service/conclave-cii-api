module SecurityService
  class Auth
    def initialize(client_id, access_token)
      @client_id = client_id
      @access_token = access_token
    end

    def sec_api_validate_token
      url = "/security/validate_token?clientid=#{@client_id}"
      conn = Faraday.new(url: ENV['SECURITY_SERVICE_URL'])
      conn.authorization :Bearer, @access_token
      resp = conn.post(url, '', { 'Content-Type' => 'application/x-www-form-urlencoded' })

      if resp.status == 200
        true if resp.body == 'true'
      else
        false
      end
    end
  end
end
