# rubocop:disable all
namespace :ccs_to_gca do
  desc "Replace CCS name with GCA in scheme_register table"
  task :update_seeds => :environment do
    SchemeRegister.find_each do |scheme|
      if(scheme.scheme_register_code == 'GB-CCS')
        scheme.update!(scheme_identifier: 'Government Commercial Agency Internal Number', scheme_uri: 'https://www.gca.gov.uk', scheme_name: 'Government Commercial Agency')
      end

      if(scheme.scheme_register_code == 'GB-PPG')
        scheme.update!(scheme_identifier: 'Government Commercial Agency PPON Number', scheme_uri: 'https://www.gca.gov.uk')
      end

      if(scheme.scheme_register_code == 'GB-EDU')
        scheme.update!(scheme_uri: 'https://www.gca.gov.uk')
      end

      if(scheme.scheme_register_code == 'GB-NHS')
        scheme.update!(scheme_uri: 'https://www.gca.gov.uk')
      end
    end
    # Uncomment if you want to check if your changes have taken effect
    # puts "Updated Scheme Registers: #{SchemeRegister.all.as_json(except: :id)}"
  end
end
# rubocop:enable all
