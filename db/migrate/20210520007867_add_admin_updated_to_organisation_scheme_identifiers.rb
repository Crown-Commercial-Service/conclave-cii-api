class AddAdminUpdatedToOrganisationSchemeIdentifiers < ActiveRecord::Migration[6.0]
  def change
    add_column :organisation_scheme_identifiers, :admin_updated, :boolean, default: false
  end
end
