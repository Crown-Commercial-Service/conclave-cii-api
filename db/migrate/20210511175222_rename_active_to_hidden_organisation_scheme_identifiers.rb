class RenameActiveToHiddenOrganisationSchemeIdentifiers < ActiveRecord::Migration[6.0]
  def change
    rename_column :organisation_scheme_identifiers, :active, :hidden
  end
end
