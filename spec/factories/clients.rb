FactoryBot.define do
  factory :client do
    name { 'Example company' }
    description { 'Example company description' }
    api_key { SecureRandom.hex(20) }
    active { true }
  end
end
