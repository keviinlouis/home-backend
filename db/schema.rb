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

ActiveRecord::Schema.define(version: 2019_09_16_232136) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bill_categories", force: :cascade do |t|
    t.string "name"
    t.string "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bill_categories_on_user_id"
  end

  create_table "bill_events", force: :cascade do |t|
    t.integer "kind"
    t.text "message"
    t.string "user_id"
    t.bigint "bill_id"
    t.jsonb "info"
    t.jsonb "readed_by"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_id"], name: "index_bill_events_on_bill_id"
    t.index ["user_id"], name: "index_bill_events_on_user_id"
  end

  create_table "bill_users", force: :cascade do |t|
    t.string "user_id"
    t.bigint "bill_id"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "percent"
    t.integer "status", default: 0
    t.float "next_percent"
    t.index ["bill_id"], name: "index_bill_users_on_bill_id"
    t.index ["user_id"], name: "index_bill_users_on_user_id"
  end

  create_table "bills", force: :cascade do |t|
    t.float "amount"
    t.string "name"
    t.text "description"
    t.date "expires_at"
    t.integer "frequency"
    t.integer "frequency_type"
    t.string "user_id"
    t.bigint "bill_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["bill_category_id"], name: "index_bills_on_bill_category_id"
    t.index ["deleted_at"], name: "index_bills_on_deleted_at"
    t.index ["user_id"], name: "index_bills_on_user_id"
  end

  create_table "invoice_users", force: :cascade do |t|
    t.float "amount"
    t.datetime "expires_at"
    t.integer "status"
    t.string "user_id"
    t.bigint "invoice_id"
    t.bigint "bill_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_user_id"], name: "index_invoice_users_on_bill_user_id"
    t.index ["invoice_id"], name: "index_invoice_users_on_invoice_id"
    t.index ["user_id"], name: "index_invoice_users_on_user_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.float "amount"
    t.datetime "expires_at"
    t.integer "number"
    t.bigint "bill_id"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_id"], name: "index_invoices_on_bill_id"
  end

  create_table "users", id: false, force: :cascade do |t|
    t.string "id", null: false
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_users_on_id", unique: true
  end

  add_foreign_key "bill_categories", "users"
  add_foreign_key "bill_events", "bills"
  add_foreign_key "bill_events", "users"
  add_foreign_key "bill_users", "bills"
  add_foreign_key "bill_users", "users"
  add_foreign_key "bills", "bill_categories"
  add_foreign_key "bills", "users"
  add_foreign_key "invoice_users", "bill_users"
  add_foreign_key "invoice_users", "invoices"
  add_foreign_key "invoice_users", "users"
  add_foreign_key "invoices", "bills"
end
