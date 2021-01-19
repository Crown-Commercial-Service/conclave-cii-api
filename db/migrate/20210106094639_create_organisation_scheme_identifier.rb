class CreateOrganisationSchemeIdentifier < ActiveRecord::Migration[6.0]
  def change
    create_table :organisation_scheme_identifiers, id: :integer do |t|
      t.bigint :ccs_org_id
      t.string :scheme_code, :limit => 20
      t.string :scheme_org_reg_number
      t.boolean :primary_scheme
      t.timestamps
    end
    add_index :organisation_scheme_identifiers, :scheme_org_reg_number, :unique => true
  end
end
