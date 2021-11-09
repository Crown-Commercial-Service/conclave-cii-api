FactoryBot.define do
  factory :organisation_scheme_identifier do
    sequence :organisationId do |n|
      "1234#{n}"
    end
    sequence :scheme_code do |n|
      "test#{n}"
    end
    sequence :scheme_org_reg_number do |n|
      "test#{n}"
    end
    primary_scheme { true }
    hidden { false }
  end
end
