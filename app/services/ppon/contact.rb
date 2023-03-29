module Ppon
  class Contact
    def build_response
      {
        name: '',
        email: '',
        telephone: '',
        faxNumber: '',
        uri: ''
      }
    end

    private

    def get_contact_value(contacts, type)
      return '' if contacts.blank?

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
