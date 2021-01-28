module FindThatCharity
  class Contact
    def initialize(result)
      super()
      @result = result
    end

    def build_response
      {
        name: '',
        email: email,
        telephone: telephone,
        faxNumber: '',
        uri: ''
      }
    end

    def email
      exists_or_null(@result['email'])
    end

    def telephone
      exists_or_null(@result['telephone'])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
