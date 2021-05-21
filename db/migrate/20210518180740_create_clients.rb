class CreateClients < ActiveRecord::Migration[6.0]
  def change
    create_table :clients, id: :integer do |t|
      t.string :name
      t.text :description
      t.string :api_key, limit: 255, unique: true
      t.boolean :active
      t.timestamps
    end
  end
end
