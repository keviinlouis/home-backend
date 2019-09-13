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

ActiveRecord::Schema.define(version: 2019_09_13_205038) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bill_categories", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bill_categories_on_user_id"
  end

  create_table "bills", force: :cascade do |t|
    t.float "amount"
    t.string "name"
    t.text "description"
    t.date "expires_at"
    t.integer "frequency"
    t.integer "frequency_type"
    t.bigint "user_id"
    t.bigint "bill_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["bill_category_id"], name: "index_bills_on_bill_category_id"
    t.index ["deleted_at"], name: "index_bills_on_deleted_at"
    t.index ["user_id"], name: "index_bills_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "bill_categories", "users"
  add_foreign_key "bills", "bill_categories"
  add_foreign_key "bills", "users"
end
