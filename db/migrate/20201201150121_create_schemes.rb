class CreateSchemes < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'
    create_table :schemes, id: :uuid do |t|
      t.string :scheme_code, unique: true
      t.string :scheme_name
      t.string :scheme_country_code
      t.boolean :external
      t.timestamps
    end
  end
end
