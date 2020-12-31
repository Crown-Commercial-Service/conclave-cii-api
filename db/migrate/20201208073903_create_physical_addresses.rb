class CreatePhysicalAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :physical_addresses, id: :integer do |t|
      t.string :street_address
      t.string :locality
      t.string :region
      t.string :postal_code
      t.string :country_code
      t.string :uprn
      t.timestamps
    end
  end
end
