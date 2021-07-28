module Common
  class ContactHelper
    def initialize(result)
      super()
      @result = result
    end

    def build_response
      {
        name: name,
        email: email,
        telephone: telephone,
        faxNumber: fax_number,
        uri: uri
      }
    end

    def name
      @result[:contactPoint].present? ? exists_or_null(@result[:contactPoint][:name]) : ''
    end

    def fax_number
      @result[:contactPoint].present? ? exists_or_null(@result[:contactPoint][:faxNumber]) : ''
    end

    def uri
      @result[:contactPoint].present? ? exists_or_null(@result[:contactPoint][:uri]) : ''
    end

    def email
      @result[:contactPoint].present? ? exists_or_null(@result[:contactPoint][:email]) : ''
    end

    def telephone
      @result[:contactPoint].present? ? exists_or_null(@result[:contactPoint][:telephone]) : ''
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
