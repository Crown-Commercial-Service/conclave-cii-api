module ApiValidations
  class OrgProfileExists
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_reader :data

    validates_presence_of :id, presence: true

    def initialize(data)
      @data = data || {}
    end

    def read_attribute_for_validation(key)
      data[key]
    end

    def ccs_organisation_exists
      return unless @data[:id]

      scheme_identifier = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: @data[:id].to_s)
      scheme_identifier[:ccs_org_id] if scheme_identifier.present?
    end
  end
end
