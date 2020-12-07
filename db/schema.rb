# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_02_035152) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "contact_points", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "contact_detail_id"
    t.uuid "organisation_scheme_identifiers_id"
    t.boolean "primary_contact"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organisation_scheme_identifiers_id"], name: "index_contact_points_on_organisation_scheme_identifiers_id"
  end

  create_table "organisation_scheme_identifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "schemes_id"
    t.string "scheme_code"
    t.integer "organisation_id"
    t.integer "scheme_reg_number"
    t.string "scheme_org_legal_name"
    t.string "scheme_org_uri"
    t.boolean "primary_scheme"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["schemes_id"], name: "index_organisation_scheme_identifiers_on_schemes_id"
  end

  create_table "schemes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "scheme_code"
    t.string "scheme_name"
    t.string "scheme_country_code"
    t.boolean "external"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "contact_points", "organisation_scheme_identifiers", column: "organisation_scheme_identifiers_id"
  add_foreign_key "organisation_scheme_identifiers", "schemes", column: "schemes_id"
end
