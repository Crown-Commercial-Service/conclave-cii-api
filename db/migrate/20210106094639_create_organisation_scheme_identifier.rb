class CreateOrganisationSchemeIdentifier < ActiveRecord::Migration[6.0]
  def change
    create_table :organisation_scheme_identifiers, id: :integer do |t|
      t.integer :organisation_id, unique: true
      t.string :scheme_code, :limit => 20
      t.string :scheme_org_reg_number
      t.boolean :primary_scheme
      t.timestamps
    end
  end
end
