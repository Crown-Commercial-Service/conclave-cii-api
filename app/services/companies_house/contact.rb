module CompaniesHouse
  class Contact
    def initialize(result)
      super()
      @error = nil
      @result = result
    end

    def build_response
      {
        name: '',
        email: '',
        telephone: '',
        faxNumber: '',
        uri: ''
      }
    end
  end
end
