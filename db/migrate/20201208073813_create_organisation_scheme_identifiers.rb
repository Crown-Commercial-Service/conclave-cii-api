class CreateOrganisationSchemeIdentifiers < ActiveRecord::Migration[6.0]
  def change
    create_table :organisation_scheme_identifiers, id: :integer do |t|
      t.integer :organisation_id
      t.string :scheme_code, :limit => 5
      t.string :scheme_org_reg_number
      t.string :scheme_org_legal_name
      t.string :scheme_business_type_id
      t.string :scheme_incorporation_date
      t.string :scheme_country_of_incoporation
      t.boolean :primary_scheme
      t.timestamps
    end
  end
end
