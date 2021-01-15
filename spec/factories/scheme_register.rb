FactoryBot.define do
  factory :scheme_register do
    scheme_register_code { 'GB-CCC' }
    scheme_name { 'Example charity orginsation' }
    scheme_uri { 'http://www.example.org.uk' }
    scheme_identifier { 'Registered Charity Number' }
    scheme_country_code { 'GB' }
  end
end
