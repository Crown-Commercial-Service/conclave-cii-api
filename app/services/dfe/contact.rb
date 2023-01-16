module Dfe
  class Contact
    def initialize(result)
      super()
      @result = result
    end

    def build_response
      {
        name: name,
        email: '',
        telephone: telephone,
        faxNumber: '',
        uri: ''
      }
    end

    def telephone
      exists_or_null(@result['TelephoneNum'])
    end

    def name
      return '' unless @result.key?('Head') && @result['Head'].key?('HeadFirstName')

      @result['Head']['HeadLastName'] ? "#{@result['Head']['HeadFirstName']} #{@result['Head']['HeadLastName']}" : @result['Head']['HeadFirstName']
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
