class CreateContactPoints < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_points, id: :integer do |t|
      t.integer :contact_detail_id
      t.integer :party_id
      t.integer :party_table_type_id
      t.integer :application_id
      t.integer :contact_method
      t.integer :contact_point_reason
      t.boolean :primary
      t.datetime :effective_from
      t.datetime :effective_to
      t.timestamps
    end
  end
end
