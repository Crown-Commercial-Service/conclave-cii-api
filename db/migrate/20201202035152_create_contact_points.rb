class CreateContactPoints < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_points, id: :uuid do |t|
      t.integer :contact_detail_id
      t.references :organisation_scheme_identifiers, foreign_key: true, type: :uuid
      t.boolean :primary_contact
      t.timestamps
    end
  end
end
