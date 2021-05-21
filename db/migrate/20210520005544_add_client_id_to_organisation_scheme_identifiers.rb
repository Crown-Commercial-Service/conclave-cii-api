class AddClientIdToOrganisationSchemeIdentifiers < ActiveRecord::Migration[6.0]
  def change
    add_column :organisation_scheme_identifiers, :client_id, :integer, default: ''
  end
end
