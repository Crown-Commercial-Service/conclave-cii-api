module ApiValidations
  class Scheme
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    validates_presence_of :scheme, :id, presence: true
    validate :buyers_reg_duplicate_search
    validate :scheme_id_exists
    validate :organisation_exists

    # used to send response relevant http status code to user
    # if validation fails.
    # remove this callback to revert back to rails default error handling
    after_validation :http_validation_response

    def initialize(data, buyers_reg: false)
      @data = data || {}
      @ccs_org_id = nil
      @buyers_reg = buyers_reg
    end

    def http_validation_response
      return ApiValidations::ApiErrorValidationResponse.new(errors.messages.keys.first, @ccs_org_id) if @buyers_reg && @ccs_org_id

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

    def id_belongs_to_same_org(org_scheme_result)
      errors.add(:duplicate_id) if org_scheme_result[:ccs_org_id].to_i != @data[:ccs_org_id].to_i
    end

    def check_duplicate(scheme_identifier)
      errors.add(:duplicate_id) if scheme_identifier.present? && @data[:ccs_org_id].blank?
      id_belongs_to_same_org(scheme_identifier) if scheme_identifier.present? && @data[:ccs_org_id].present?
    end

    def organisation_exists
      return unless @data[:id]

      data_id = Common::ApiHelper.filter_charity_number(@data[:id], @data[:scheme])
      scheme_identifier = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: Common::ApiHelper.remove_white_space_from_id(data_id).to_s)
      check_duplicate(scheme_identifier)
    end

    def buyers_reg_duplicate_search
      return unless @data[:id]

      data_id = Common::ApiHelper.filter_charity_number(@data[:id], @data[:scheme])
      scheme_identifier = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: Common::ApiHelper.remove_white_space_from_id(data_id).to_s)
      @ccs_org_id = scheme_identifier['ccs_org_id'] if scheme_identifier && scheme_identifier['ccs_org_id']
    end

    def buyers_reg_duplicate_id
      @ccs_org_id
    end
  end
end
