module Dfe
  class Contact
    def initialize(result)
      super()
      @result = result
    end

    def build_response
      {
        name: '',
        email: '',
        telephone: telephone,
        faxNumber: '',
        uri: url
      }
    end

    def telephone
      exists_or_null(@result['TelephoneNum'])
    end

    def url
      exists_or_null(@result['SchoolWebsite'])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
