module Ppon
  class Indentifier
    def initialize(organisation_code, ccs_org_id)
      super()
      @organisation_code = organisation_code
      @ccs_org_id = ccs_org_id
    end

    def build_response
      {
        scheme: 'GB-PPG',
        id: @organisation_code.to_s,
        legalName: legal_name.to_s,
        uri: ''
      }
    end

    def legal_name
      # Use ccs_org_id to lookup organisation's legal name, and apply to JSON in build_response method.
      # THIS COULD ONLY BE USED WHEN ADDING AS ADDITIONAL IDENTIFIER, BECAUSE THE ORGANISATION MUST ALREADY EXIST IN CII, TO LOOKUP LEGAL NAME.
      ''
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
