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

ActiveRecord::Schema.define(version: 2019_11_25_191835) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bill_categories", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bill_categories_on_user_id"
  end

  create_table "bill_events", force: :cascade do |t|
    t.integer "kind"
    t.text "message"
    t.bigint "user_id"
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
    t.bigint "user_id"
    t.bigint "bill_id"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "percent"
    t.integer "status", default: 0
    t.float "next_percent"
    t.float "next_amount"
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
    t.bigint "user_id"
    t.bigint "bill_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["bill_category_id"], name: "index_bills_on_bill_category_id"
    t.index ["deleted_at"], name: "index_bills_on_deleted_at"
    t.index ["user_id"], name: "index_bills_on_user_id"
  end

  create_table "devices", force: :cascade do |t|
    t.bigint "user_id"
    t.text "fcm_token"
    t.integer "deivce_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "invoice_users", force: :cascade do |t|
    t.float "amount"
    t.datetime "expires_at"
    t.integer "status"
    t.bigint "user_id"
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

  create_table "notifications", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "user_id"
    t.string "resource_type"
    t.bigint "resource_id"
    t.boolean "opened"
    t.datetime "opened_at"
    t.integer "notification_type"
    t.string "message_error"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["opened"], name: "index_notifications_on_opened"
    t.index ["resource_type", "resource_id"], name: "index_notifications_on_resource_type_and_resource_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "rpush_apps", force: :cascade do |t|
    t.string "name", null: false
    t.string "environment"
    t.text "certificate"
    t.string "password"
    t.integer "connections", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", null: false
    t.string "auth_key"
    t.string "client_id"
    t.string "client_secret"
    t.string "access_token"
    t.datetime "access_token_expiration"
    t.text "apn_key"
    t.string "apn_key_id"
    t.string "team_id"
    t.string "bundle_id"
    t.boolean "feedback_enabled", default: true
  end

  create_table "rpush_feedback", force: :cascade do |t|
    t.string "device_token"
    t.datetime "failed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "app_id"
    t.index ["device_token"], name: "index_rpush_feedback_on_device_token"
  end

  create_table "rpush_notifications", force: :cascade do |t|
    t.integer "badge"
    t.string "device_token"
    t.string "sound"
    t.text "alert"
    t.text "data"
    t.integer "expiry", default: 86400
    t.boolean "delivered", default: false, null: false
    t.datetime "delivered_at"
    t.boolean "failed", default: false, null: false
    t.datetime "failed_at"
    t.integer "error_code"
    t.text "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "alert_is_json", default: false, null: false
    t.string "type", null: false
    t.string "collapse_key"
    t.boolean "delay_while_idle", default: false, null: false
    t.text "registration_ids"
    t.integer "app_id", null: false
    t.integer "retries", default: 0
    t.string "uri"
    t.datetime "fail_after"
    t.boolean "processing", default: false, null: false
    t.integer "priority"
    t.text "url_args"
    t.string "category"
    t.boolean "content_available", default: false, null: false
    t.text "notification"
    t.boolean "mutable_content", default: false, null: false
    t.string "external_device_id"
    t.string "thread_id"
    t.boolean "dry_run", default: false, null: false
    t.index ["delivered", "failed", "processing", "deliver_after", "created_at"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "password_digest"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
  end

  add_foreign_key "bill_categories", "users"
  add_foreign_key "bill_events", "bills"
  add_foreign_key "bill_events", "users"
  add_foreign_key "bill_users", "bills"
  add_foreign_key "bill_users", "users"
  add_foreign_key "bills", "bill_categories"
  add_foreign_key "bills", "users"
  add_foreign_key "devices", "users"
  add_foreign_key "invoice_users", "bill_users"
  add_foreign_key "invoice_users", "invoices"
  add_foreign_key "invoice_users", "users"
  add_foreign_key "invoices", "bills"
  add_foreign_key "notifications", "users"
end
