class CreateOrganisationIdentifierContactPointReasons < ActiveRecord::Migration[6.0]
  def change
    create_table :organisation_identifier_contact_point_reasons, id: :integer do |t|
      t.string :reason_name
      t.string :reason_description
      t.timestamps
    end
  end
end
