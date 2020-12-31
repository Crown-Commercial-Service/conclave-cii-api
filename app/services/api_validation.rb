class ApiValidation
  include ActiveModel::Validations

  attr_reader :data

  validates_presence_of :scheme_id, :orginasation_id, presence: true
  validate :scheme_id_exists

  def initialize(data)
    @data = data || {}
  end

  def read_attribute_for_validation(key)
    data[key]
  end

  def scheme_id_exists
    return unless data[:scheme_id]

    scheme = SchemeRegister.find_by(scheme_register_code: data[:scheme_id].to_s)
    errors.add(:scheme_id, 'No such scheme registered') if scheme.blank?
  end
end
