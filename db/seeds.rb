# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
[
  {scheme_name: 'Companies House', scheme_register_code: 'GB-COH', scheme_uri: 'https://api.company-information.service.gov.uk', scheme_country_code: 'GB', scheme_identifier: 'Company Registration Number'},
  {scheme_name: 'Dun & Bradstreet', scheme_register_code: 'US-DUN', scheme_uri: 'https://plus.dnb.com', scheme_country_code: 'US', scheme_identifier: 'DUNS Number'},
  {scheme_name: 'Charity Commission for England and Wales', scheme_register_code: 'GB-CHC', scheme_uri: 'https://findthatcharity.uk', scheme_country_code: 'GB', scheme_identifier: 'Registered Charity Number'},
  {scheme_name: 'Office of The Scottish Charity Regulator (OSCR)', scheme_register_code: 'GB-SC', scheme_uri: 'https://findthatcharity.uk', scheme_country_code: 'GB', scheme_identifier: 'Registered Charity Number'},
  {scheme_name: 'The Charity Commission for Northern Ireland', scheme_register_code: 'GB-NIC', scheme_uri: 'https://findthatcharity.uk', scheme_country_code: 'GB', scheme_identifier: 'Registered Charity Number'},
  {scheme_name: 'National Health Service Organisations Registry', scheme_register_code: 'GB-NHS', scheme_uri: 'https://www.crowncommercial.gov.uk', scheme_country_code: 'GB', scheme_identifier: 'NHS Registered Number'},
  {scheme_name: 'Department for Education', scheme_register_code: 'GB-EDU', scheme_uri: 'https://www.crowncommercial.gov.uk', scheme_country_code: 'GB', scheme_identifier: 'Registered DfE URN'},
  {scheme_name: 'The Crown Commercial Service', scheme_register_code: 'GB-CCS', scheme_uri: 'https://www.crowncommercial.gov.uk', scheme_country_code: 'GB', scheme_identifier: 'Crown Commercial Service Internal Number'},
  {scheme_name: 'The Crown Commercial Service Public Procurement Organisation Registry', scheme_register_code: 'GB-PPG', scheme_uri: 'https://www.crowncommercial.gov.uk', scheme_country_code: 'GB', scheme_identifier: 'Crown Commercial Service PPON Number'}

].each do |rec|
  SchemeRegister.find_or_create_by(scheme_name: rec[:scheme_name], scheme_register_code: rec[:scheme_register_code], scheme_uri: rec[:scheme_uri], scheme_country_code: rec[:scheme_country_code], scheme_identifier: rec[:scheme_identifier])
end