module Spotlight
  class Contact
    def initialize(result)
      super()
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
