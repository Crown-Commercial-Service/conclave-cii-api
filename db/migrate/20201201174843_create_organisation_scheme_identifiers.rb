class CreateOrganisationSchemeIdentifiers < ActiveRecord::Migration[6.0]
  def change
    create_table :organisation_scheme_identifiers, id: :uuid do |t|
      t.references :schemes, foreign_key: true, type: :uuid
      t.string :scheme_code
      t.integer :organisation_id
      t.integer :scheme_reg_number
      t.string :scheme_org_legal_name
      t.string :scheme_org_uri
      t.boolean :primary_scheme, unique: true
      t.timestamps
    end
  end
end
