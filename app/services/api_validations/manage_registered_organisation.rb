module ApiValidations
  class ManageRegisteredOrganisation
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_reader :data

    validates_presence_of :organisationId, presence: true
    validate :validate_registered_organisationId

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

    def validate_registered_organisationId
      validate = OrganisationSchemeIdentifier.find_by(organisationId: @data[:organisationId].to_s)
      errors.add(:organisationId_not_found, '') if validate.blank?
    end
  end
end
