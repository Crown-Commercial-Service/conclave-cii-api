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
      @result && @result[:contactPoint].present? ? exists_or_null(@result[:contactPoint][:name]) : ''
    end

    def fax_number
      @result && @result[:contactPoint].present? ? exists_or_null(@result[:contactPoint][:faxNumber]) : ''
    end

    def uri
      @result && @result[:contactPoint].present? ? exists_or_null(@result[:contactPoint][:uri]) : ''
    end

    def email
      @result && @result[:contactPoint].present? ? exists_or_null(@result[:contactPoint][:email]) : ''
    end

    def telephone
      @result && @result[:contactPoint].present? ? exists_or_null(@result[:contactPoint][:telephone]) : ''
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
