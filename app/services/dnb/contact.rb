module Dnb
  class Contact
    def initialize(result)
      super()
      @result = result
    end

    def build_response
      {
        'name': '',
        'email': '',
        'telephone': '',
        'faxNumber': '',
        'url': ''
      }
    end
  end
end
