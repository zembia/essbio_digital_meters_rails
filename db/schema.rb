# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_10_07_181012) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "alertas", force: :cascade do |t|
    t.string "deveui"
    t.integer "lectura1"
    t.string "statemesages"
    t.datetime "logdate"
    t.date "fecha_logdate"
    t.time "hora_logdate"
  end

  create_table "applied_fee_types", force: :cascade do |t|
    t.string "label"
    t.boolean "base"
    t.boolean "ap"
    t.boolean "al"
    t.boolean "tas"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "apps", force: :cascade do |t|
    t.string "name"
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_apps_on_name", unique: true
    t.index ["tag"], name: "index_apps_on_tag", unique: true
  end

  create_table "client_meters", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "meter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meter_id"], name: "index_client_meters_on_meter_id"
    t.index ["user_id"], name: "index_client_meters_on_user_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "service_number"
    t.string "address"
    t.string "client_name"
    t.string "route"
    t.string "phone_number"
    t.string "mobile_number"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "group_id"
    t.bigint "location_id"
    t.index ["group_id"], name: "index_clients_on_group_id"
    t.index ["location_id"], name: "index_clients_on_location_id"
  end

  create_table "consumos_por_hora", force: :cascade do |t|
    t.string "deveui"
    t.datetime "logdate"
    t.date "fecha_log"
    t.time "hora_log"
    t.date "fecha"
    t.time "hora"
    t.integer "consumo"
    t.integer "consumo_acumulado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "fecha_hora"
  end

  create_table "consumptions", force: :cascade do |t|
    t.decimal "value"
    t.decimal "accumulated_value"
    t.bigint "meter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "measured_at", precision: nil
    t.index ["meter_id"], name: "index_consumptions_on_meter_id"
  end

  create_table "data_summaries", force: :cascade do |t|
    t.decimal "current_consumption"
    t.decimal "current_consumption_clp"
    t.decimal "projected_consumption_clp"
    t.bigint "meter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meter_id"], name: "index_data_summaries_on_meter_id"
  end

  create_table "file_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tag"
  end

  create_table "groups", force: :cascade do |t|
    t.integer "number"
    t.string "description"
  end

  create_table "historic_consumptions", force: :cascade do |t|
    t.decimal "value"
    t.bigint "meter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "month"
    t.index ["meter_id"], name: "index_historic_consumptions_on_meter_id"
  end

  create_table "locations", force: :cascade do |t|
    t.integer "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "base_fee"
    t.float "ap_fee"
    t.float "al_fee"
    t.float "tas_fee"
    t.index ["code"], name: "index_locations_on_code"
  end

  create_table "measurement_dates", force: :cascade do |t|
    t.bigint "group_id"
    t.date "last_date"
    t.date "current_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "month"
    t.index ["group_id"], name: "index_measurement_dates_on_group_id"
  end

  create_table "meters", force: :cascade do |t|
    t.string "meter_number"
    t.string "deveui"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deveui"], name: "index_meters_on_deveui", unique: true
  end

  create_table "notification_types", force: :cascade do |t|
    t.string "name"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "notification_type_id"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "generated_at", precision: nil
    t.index ["notification_type_id"], name: "index_notifications_on_notification_type_id"
  end

  create_table "uploaded_files", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "file_type_id", null: false
    t.index ["file_type_id"], name: "index_uploaded_files_on_file_type_id"
  end

  create_table "user_clients", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "client_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_user_clients_on_client_id"
    t.index ["user_id"], name: "index_user_clients_on_user_id"
  end

  create_table "user_notifications", force: :cascade do |t|
    t.bigint "notification_id"
    t.bigint "user_id"
    t.datetime "seen_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id"], name: "index_user_notifications_on_notification_id"
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "app_id"
    t.index ["app_id"], name: "index_users_on_app_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "zones", force: :cascade do |t|
    t.string "name"
    t.decimal "neighbor_mean"
    t.decimal "efficient_neighbor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "client_meters", "meters"
  add_foreign_key "client_meters", "users"
  add_foreign_key "clients", "groups"
  add_foreign_key "clients", "locations"
  add_foreign_key "consumptions", "meters"
  add_foreign_key "data_summaries", "meters"
  add_foreign_key "historic_consumptions", "meters"
  add_foreign_key "measurement_dates", "groups"
  add_foreign_key "notifications", "notification_types"
  add_foreign_key "uploaded_files", "file_types"
  add_foreign_key "user_clients", "clients"
  add_foreign_key "user_clients", "users"
  add_foreign_key "user_notifications", "notifications"
  add_foreign_key "user_notifications", "users"
  add_foreign_key "users", "apps"
end
