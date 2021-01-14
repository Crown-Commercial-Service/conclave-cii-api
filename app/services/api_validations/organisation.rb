module ApiValidations
  class Organisation
    include ActiveModel::Validations

    attr_reader :data

    validates_presence_of :organisation, presence: true
    validate :organisation_exists
    validate :validate_scheme_params

    def initialize(data)
      @data = data || {}
    end

    def read_attribute_for_validation(key)
      data[key]
    end

    def organisation_exists
      errors.add(:organisation, 'must be an array') unless data[:organisation].is_a?(Array)
    end

    def validate_scheme_params
      data['organisation'].each do |user_params|
        validate = ApiValidations::Scheme.new(user_params)
        errors.add(:organisation, validate.errors) unless validate.valid?
      end
    end
  end
end
