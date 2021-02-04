module ApiValidations
  class Organisation
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_reader :data

    validates_presence_of :organisation, presence: true
    validate :organisation_exists
    validate :validate_scheme_params

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

    def organisation_exists
      errors.add(:organisation) unless data[:organisation].is_a?(Array)
    end

    def validate_scheme_params
      data['organisation'].each do |user_params|
        validate = ApiValidations::Scheme.new(user_params)
        errors.add(:organisation, validate.errors) unless validate.valid?
      end
    end
  end
end
