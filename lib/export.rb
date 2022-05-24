module Export
    include ActionController::MimeResponds
    include Authorize::Token
    require 'csv'
    require 'date'
    require 'fileutils'
    require 'azure/storage/blob'

    def self.begin
        Rails.logger.info "BEGINNING DATA EXPORT JOB..."

        directory = "#{Rails.root}/public/export"
        file_path = "#{Rails.root}/public/export/#{(Date.today - 1)}_Organisations.csv"

        FileUtils.mkdir_p directory unless File.directory?(directory)

        csv_generated = generate_csv_export(file_path)
        return upload_to_azure(file_path) if csv_generated

        Rails.logger.info "NO DATA TO EXPORT - JOB COMPLETE"
    end

    def self.generate_csv_export(file_path)
        Rails.logger.info "GENERATING #{file_path}"

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

    private

    def self.upload_to_azure(file_path)
        Rails.logger.info "UPLOADING #{file_path} > #{azure_container_name}"

        file_name = file_path.split('/')[3]
        file_content = File.open(file_path, "rb") { |file| file.read }
        azure_client.create_block_blob(azure_container_name, file_name, file_content)

        delete_file(file_path)
        Rails.logger.info "DATA EXPORTED - JOB COMPLETE"
    end

    def azure_client
        @azure_client ||= Azure::Storage::Blob::BlobService.create(azure_client_config)
    end

    def azure_client_config
        {
          storage_account_name: ENV['AZURE_ACCOUNT_NAME'],
          storage_access_key: ENV['AZURE_ACCOUNT_KEY']
        }
    end

    def azure_container_name
        ENV['AZURE_CONTAINER_NAME']
    end

    def self.delete_file(file_path)
        File.delete(file_path) if File.exist?(file_path)
    end

    def self.get_organisations
        OrganisationSchemeIdentifier.where(updated_at: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day)
    end
end
