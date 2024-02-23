module RegistryUpdate
  class ContactService
    def initialize(ccs_org_id, registry_result)
      @ccs_org_id = ccs_org_id
      @api_key = ENV.fetch('X_API_KEY_CONTACT_API_SERVICE', nil)
      @registry_result = registry_result
      @user_contact = RegistryUpdate::UserContact.new(registry_result)
      @user_address = RegistryUpdate::OrganisationAddress.new(registry_result)
      @conn = Common::ApiHelper.faraday_new(url: ENV.fetch('CONTACT_API_SERVICE_URL', nil))
    end

    def update_contact
      resp = update_org_contact_details(@conn)
      # ApiLogging::Logger.error("CONTACT SERVICE API| method:connect_contact_api, #{resp.to_json}") if resp.status != 200
    rescue StandardError => e
      ApiLogging::Logger.fatal("CONTACT SERVICE API| method:connect_contact_api, #{e.to_json}")
    end

    def get_org_contact_details(contact_conn)
      contact_conn.get("contact-service/organisations/#{@ccs_org_id}/registry-contact") do |req|
        req.headers['x-api-key'] =  @api_key
      end
    end

    def update_registry_contact_payload
      @user_address.address_payload.merge(@user_contact.contact_payload)
    end

    def update_org_contact_details(contact_conn)
      contact_conn.patch("contact-service/organisations/#{@ccs_org_id}/registry-contact", update_registry_contact_payload.to_json, 'Content-Type' => 'application/json') do |req|
        req.headers['x-api-key'] =  @api_key
      end
    end
  end
end
