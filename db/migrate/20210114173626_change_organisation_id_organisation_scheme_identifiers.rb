class ChangeOrganisationIdOrganisationSchemeIdentifiers < ActiveRecord::Migration[6.0]
  def up
    rename_column :organisation_scheme_identifiers, :organisation_id, :ccs_org_id
  end
end
