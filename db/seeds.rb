# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
SchemeRegister.create(scheme_name: 'Companies House', scheme_register_code: 'GB-COH', scheme_uri: 'https://api.company-information.service.gov.uk', scheme_country_code: 'GB', scheme_identifier: 'Company Registration Number')
SchemeRegister.create(scheme_name: 'Dun and Bradstreet', scheme_register_code: 'US-DUN', scheme_uri: 'https://api.company-information.service.gov.uk', scheme_country_code: 'US', scheme_identifier: 'DUNS Number')
SchemeRegister.create(scheme_name: 'Charities Commission for England and Wales', scheme_register_code: 'GB-CHC', scheme_uri: 'https://findthatcharity.uk', scheme_country_code: 'GB', scheme_identifier: 'Registered Charity Number')
SchemeRegister.create(scheme_name: 'Scottish Charities Commission', scheme_register_code: 'GB-SC', scheme_uri: 'https://findthatcharity.uk', scheme_country_code: 'GB', scheme_identifier: 'Registered Charity Number')
SchemeRegister.create(scheme_name: 'Northern Ireland Charities Commission', scheme_register_code: 'GB-NIC', scheme_uri: 'https://findthatcharity.uk', scheme_country_code: 'GB', scheme_identifier: 'Registered Charity Number')