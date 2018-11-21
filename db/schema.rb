# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_11_21_114906) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "people", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "maiden_name"
    t.string "gender", null: false
    t.integer "depth", null: false
    t.bigint "spouse_id"
    t.bigint "mother_id"
    t.bigint "father_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["father_id"], name: "index_people_on_father_id"
    t.index ["mother_id"], name: "index_people_on_mother_id"
    t.index ["spouse_id"], name: "index_people_on_spouse_id"
  end

end
