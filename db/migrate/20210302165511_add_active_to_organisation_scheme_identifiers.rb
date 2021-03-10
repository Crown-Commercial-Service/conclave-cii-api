class AddActiveToOrganisationSchemeIdentifiers < ActiveRecord::Migration[6.0]
  def change
    add_column :organisation_scheme_identifiers, :active, :boolean, default: false
  end
end
