module ApiValidations
  class BuyerExists
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_reader :data

    validates_presence_of :id, presence: true
    validate :ccs_organisation_exists
    # used to send response relevant http status code to user
    # if validation fails.
    # remove this callback to revert back to rails default error handling
    after_validation :http_validation_response

    def initialize(data)
      @data = data || {}
    end

    def http_validation_response
      ApiValidations::ApiErrorValidationResponse.new(errors.messages.keys.first)
    end

    def read_attribute_for_validation(key)
      data[key]
    end

    def ccs_organisation_exists
      return unless @data[:id]

      scheme_identifier = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: @data[:id].to_s)
      errors.add(:duplicate_id) if scheme_identifier.present?
    end
  end
end
