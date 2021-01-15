class CreateSchemeRegisters < ActiveRecord::Migration[6.0]
  def change
    create_table :scheme_registers , id: :integer do |t|
      t.string :scheme_register_code, :limit => 20
      t.string :scheme_name
      t.string :scheme_uri, :limit => 200
      t.string :scheme_identifier
      t.string :scheme_country_code, :limit => 10
      t.integer :rank
      t.timestamps
    end
  end
end
