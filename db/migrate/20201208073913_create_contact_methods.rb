class CreateContactMethods < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_methods, id: :integer do |t|
      t.string :contact_method_name
      t.timestamps
    end
  end
end
