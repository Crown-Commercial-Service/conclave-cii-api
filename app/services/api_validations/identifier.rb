module ApiValidations
  class Identifier
    include ActiveModel::Validations

    validates_presence_of :scheme, :id, presence: true
    validates :id, numericality: true
    validate :scheme_id_exists
    validate :organisation_exists

    def initialize(data)
      @data = data || {}
    end

    def read_attribute_for_validation(key)
      @data[key]
    end

    def scheme_id_exists
      return unless @data[:scheme]

      scheme = SchemeRegister.find_by(scheme_register_code: @data[:scheme].to_s)
      errors.add(:scheme, 'No such scheme registered') if scheme.blank?
    end

    def organisation_exists
      return unless @data[:id]

      scheme = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: @data[:id].to_s)
      errors.add(:id, "Id already exists #{@data[:id]}") if scheme.present?
    end
  end
end
