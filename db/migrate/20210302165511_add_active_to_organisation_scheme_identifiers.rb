class AddActiveToOrganisationSchemeIdentifiers < ActiveRecord::Migration[6.0]
  def change
    add_column :organisation_scheme_identifiers, :hidden, :boolean, default: false
  end
end
