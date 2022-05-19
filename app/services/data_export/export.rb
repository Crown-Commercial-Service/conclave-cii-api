module DataExport
    class Export
        include ActionController::MimeResponds
        include Authorize::Token
        require 'csv'
        require 'date'
        require 'fileutils'

        def index
            puts "BEGIN!"
            directory = "#{Rails.root}/public/export"
            file_path = "#{Rails.root}/public/export/#{(Date.today - 1)}_Organisations.csv"

            FileUtils.mkdir_p directory unless File.directory?(directory)
            

            csv_generated = generate_csv_export(file_path)
            upload_to_azure(file_path) if csv_generated
        end

        def generate_csv_export(file_path)     
            organisations = get_organisations
            return false unless organisations.any?

            CSV.open( file_path, 'w' ) do |writer|
                writer << organisations.first.attributes.map { |a,v| a }
                organisations.each do |s|
                    writer << s.attributes.map { |a,v| v }
                end
            end

            return true
        end

        def upload_to_azure(file_path)
            puts "UPLOADED!!!"
            delete_file(file_path)
        end

        def delete_file(file_path)
            File.delete(file_path) if File.exist?(file_path)
        end

        def get_organisations
            OrganisationSchemeIdentifier.where(updated_at: (Date.yesterday-1).beginning_of_day..(Date.yesterday-1).end_of_day)
        end
    end
end