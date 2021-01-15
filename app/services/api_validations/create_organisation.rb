module ApiValidations
  class CreateOrganisation
    include ActiveModel::Validations

    attr_reader :data

    validates_presence_of :identifier, presence: true
    validate :additional_identifiers_exists
    validate :validate_identifiers

    def initialize(data)
      @data = data || {}
    end

    def read_attribute_for_validation(key)
      data[key]
    end

    def additional_identifiers_exists
      validate_additional_identifiers if data[:additional_identifiers].present?
    end

    def validate_additional_identifiers
      data['additional_identifiers'].each do |user_params|
        validate = ApiValidations::Scheme.new(user_params)
        errors.add(:additional_identifiers, validate.errors) unless validate.valid?
      end
    end

    def validate_identifiers
      validate = ApiValidations::Scheme.new(data['identifier'])
      errors.add(:identifier, validate.errors) unless validate.valid?
    end
  end
end
