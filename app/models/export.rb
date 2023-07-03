class Export
  include ActionController::MimeResponds
  include Authorize::Token
  require 'csv'
  require 'date'
  require 'fileutils'
  require 'azure/storage/blob'

  def self.begin
    Rails.logger.info 'BEGINNING DATA EXPORT JOB...'

    directory = Rails.root.join('public/export').to_s
    file_path = Rails.root.join("public/export/#{Date.yesterday}_Organisations.csv").to_s

    FileUtils.mkdir_p directory unless File.directory?(directory)

    csv_generated = generate_csv_export(file_path)
    return upload_to_azure(file_path) if csv_generated

    Rails.logger.info 'NO DATA TO EXPORT - JOB COMPLETE'
    nil
  end

  def self.generate_csv_export(file_path)
    Rails.logger.info "GENERATING #{file_path}"

    organisations = find_organisations
    return failed unless organisations.any?

    CSV.open(file_path, 'w') do |writer|
      writer << organisations.first.attributes.map { |a, _v| a }
      organisations.each do |s|
        writer << s.attributes.map { |_a, v| v }
      end
    end

    success
  end

  def self.upload_to_azure(file_path)
    Rails.logger.info "UPLOADING #{file_path} > #{azure_container_name}"

    file_name = "#{Date.yesterday}_Organisations.csv"
    file_content = File.binread(file_path)
    azure_client.create_block_blob(azure_container_name, file_name, file_content)

    delete_file(file_path)
    Rails.logger.info 'DATA EXPORTED - JOB COMPLETE'
  end

  def self.azure_client
    @azure_client ||= Azure::Storage::Blob::BlobService.create(azure_client_config)
  end

  def self.azure_client_config
    {
      storage_account_name: ENV.fetch('AZURE_ACCOUNT_NAME', nil),
      storage_access_key: ENV.fetch('AZURE_ACCOUNT_KEY', nil)
    }
  end

  def self.azure_container_name
    ENV.fetch('AZURE_CONTAINER_NAME', 'ContainerName')
  end

  def self.delete_file(file_path)
    File.delete(file_path) if File.exist?(file_path)
  end

  def self.find_organisations
    OrganisationSchemeIdentifier.where(updated_at: Date.yesterday.all_day)
  end

  def self.success
    true
  end

  def self.failed
    false
  end
end
