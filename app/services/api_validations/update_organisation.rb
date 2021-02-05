module ApiValidations
  class UpdateOrganisation
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_reader :data

    validates_presence_of :identifier, :ccs_org_id, presence: true 
    validate :validate_identifiers

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

    def validate_identifiers
      validate = ApiValidations::Scheme.new(data['identifier'])
      errors.add(:identifier, validate.errors) unless validate.valid?
    end

    def organisation_exists
      return unless @data[:ccs_ord_id]
      scheme = OrganisationSchemeIdentifier.find_by(ccs_ord_id: data[:ccs_ord_id].to_s)
      errors.add(:duplicate_id) if scheme.present?
    end
  end
end