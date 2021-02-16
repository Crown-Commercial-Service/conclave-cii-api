module ApiValidations
  class Scheme
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    validates_presence_of :scheme, :id, presence: true
    validate :scheme_id_exists
    validate :organisation_exists

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
      @data[key]
    end

    def scheme_id_exists
      return unless @data[:scheme]

      scheme = SchemeRegister.find_by(scheme_register_code: (@data[:scheme]).to_s)
      errors.add(:no_scheme_found) if scheme.blank?
    end

    def organisation_exists
      return unless @data[:id]

      scheme = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: (@data[:id]).to_s)
      errors.add(:duplicate_id) if scheme.present?
    end
  end
end
