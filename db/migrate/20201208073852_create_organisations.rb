class CreateOrganisations < ActiveRecord::Migration[6.0]
  def change
    create_table :organisations, id: :integer do |t|
      t.string :scheme_reg_number
      t.string :legal_name
      t.string :organisation_uri
      t.string :business_type
      t.string :incorporation_date
      t.string :incorporation_country
      t.integer :status
      t.integer :parent_org_id
      t.boolean :right_to_buy
      t.integer :state
      t.timestamps
    end
  end
end
