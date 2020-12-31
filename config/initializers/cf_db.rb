begin
  vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
  ENV['CCS_DEFAULT_DB_HOST'] = vcap_services['postgres'][0]['credentials']['host'].to_s
  ENV['CCS_DEFAULT_DB_PORT'] = vcap_services['postgres'][0]['credentials']['port'].to_s
  ENV['CCS_DEFAULT_DB_NAME'] = vcap_services['postgres'][0]['credentials']['name'].to_s
  ENV['CCS_DEFAULT_DB_USER'] = vcap_services['postgres'][0]['credentials']['username'].to_s
  ENV['CCS_DEFAULT_DB_PASSWORD'] = vcap_services['postgres'][0]['credentials']['password'].to_s
rescue StandardError => e
  #
end
