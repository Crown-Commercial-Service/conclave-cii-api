module ApiValidations
  class ManageOrganisation
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_reader :data

    validates_presence_of :scheme, :id, :organisation_id, presence: true
    validate :validate_identifiers
    validate :validate_organisation_id

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
      identifier = {}
      identifier[:organisation_id] = @data[:organisation_id]
      identifier[:scheme] = @data[:scheme]
      identifier[:id] = @data[:id]
      validate = ApiValidations::Scheme.new(identifier)
      errors.add(:identifier, validate.errors) unless validate.valid?
    end

    def validate_organisation_id
      validate = OrganisationSchemeIdentifier.find_by(organisation_id: @data[:organisation_id].to_s)
      errors.add(:organisation_id_not_found, '') if validate.blank?
    end
  end
end
