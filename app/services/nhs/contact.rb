module Nhs
  class Contact
    def initialize(result)
      super()
      @result = result
    end

    def build_response
      {
        name: '',
        email: '',
        telephone: exists_or_null(telephone),
        faxNumber: exists_or_null(fax),
        uri: exists_or_null(uri)
      }
    end

    def telephone
      "#{get_contact_value(@result['Organisation']['Contacts']['Contact'], 'tel')}" if @result['Organisation']['Contacts'].present?
    end

    def fax
      "#{get_contact_value(@result['Organisation']['Contacts']['Contact'], 'fax')}" if @result['Organisation']['Contacts'].present?
    end

    def uri
      "#{get_contact_value(@result['Organisation']['Contacts']['Contact'], 'http')}" if @result['Organisation']['Contacts'].present?
    end

    private

    def get_contact_value(contacts, type)
      return '' unless contacts.present?

      contacts.each do |contact|
        return contact['value'] if contact['type'] == type.to_s
      end
      ''
    end

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
