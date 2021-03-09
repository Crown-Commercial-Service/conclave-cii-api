class AddLegalNameAndUriToOrganisationSchemeIdentifiers < ActiveRecord::Migration[6.0]
  def change
    add_column :organisation_scheme_identifiers, :uri, :string, default: ''
    add_column :organisation_scheme_identifiers, :legal_name, :string, default: ''
    add_index :organisation_scheme_identifiers, :scheme_code
    add_index :organisation_scheme_identifiers, :ccs_org_id
  end
end
