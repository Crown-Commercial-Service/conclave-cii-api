module ApiValidations
  class Scheme
    include ActiveModel::Validations

    attr_reader :data

    validates_presence_of :scheme, :id, presence: true
    validates :id, numericality: true
    validate :scheme_id_exists

    def initialize(data)
      @data = data || {}
    end

    def read_attribute_for_validation(key)
      data[key]
    end

    def scheme_id_exists
      return unless data[:scheme]

      scheme = SchemeRegister.find_by(scheme_register_code: "#{data[:scheme].to_s}")
      errors.add(:scheme, 'No such scheme registered') if scheme.blank?
    end
  end
end
