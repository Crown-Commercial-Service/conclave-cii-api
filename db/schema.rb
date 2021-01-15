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

ActiveRecord::Schema.define(version: 2021_01_14_173626) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "organisation_scheme_identifiers", id: :serial, force: :cascade do |t|
    t.integer "ccs_org_id"
    t.string "scheme_code", limit: 20
    t.string "scheme_org_reg_number"
    t.boolean "primary_scheme"
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
