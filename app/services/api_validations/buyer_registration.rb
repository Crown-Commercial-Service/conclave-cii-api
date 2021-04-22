module ApiValidations
  class BuyerRegistration
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_reader :data

    validates_presence_of :account_id_type, :account_id, presence: true
    validate :validate_account_id_type

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

    def validate_account_id_type
      errors.add(:account_id_type_does_not_exist) unless Common::SalesforceSearchIds.account_id_types.include? @data[:account_id_type].to_s
    end
  end
end
