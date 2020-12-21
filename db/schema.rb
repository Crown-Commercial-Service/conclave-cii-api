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

ActiveRecord::Schema.define(version: 2020_12_08_073913) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "contact_methods", id: :serial, force: :cascade do |t|
    t.string "contact_method_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "contact_points", id: :serial, force: :cascade do |t|
    t.integer "contact_detail_id"
    t.integer "party_id"
    t.integer "party_table_type_id"
    t.integer "application_id"
    t.integer "contact_method"
    t.integer "contact_point_reason"
    t.boolean "primary"
    t.datetime "effective_from"
    t.datetime "effective_to"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "organisation_identifier_contact_point_reasons", id: :serial, force: :cascade do |t|
    t.string "reason_name"
    t.string "reason_description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "organisation_scheme_identifiers", id: :serial, force: :cascade do |t|
    t.integer "organisation_id"
    t.string "scheme_code", limit: 5
    t.string "scheme_org_reg_number"
    t.string "scheme_org_legal_name"
    t.string "scheme_business_type_id"
    t.string "scheme_incorporation_date"
    t.string "scheme_country_of_incoporation"
    t.boolean "primary_scheme"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "organisations", id: :serial, force: :cascade do |t|
    t.string "scheme_reg_number"
    t.string "legal_name"
    t.string "organisation_uri"
    t.string "business_type"
    t.string "incorporation_date"
    t.string "incorporation_country"
    t.integer "status"
    t.integer "parent_org_id"
    t.boolean "right_to_buy"
    t.integer "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "physical_addresses", id: :serial, force: :cascade do |t|
    t.string "street_address"
    t.string "locality"
    t.string "region"
    t.string "postal_code"
    t.string "country_code"
    t.string "uprn"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "scheme_registers", id: :serial, force: :cascade do |t|
    t.string "scheme_register_code", limit: 20
    t.string "scheme_name"
    t.string "scheme_uri", limit: 200
    t.string "scheme_identifier"
    t.string "scheme_country_code", limit: 10
    t.integer "rank"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
