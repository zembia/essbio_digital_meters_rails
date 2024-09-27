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

ActiveRecord::Schema[7.2].define(version: 2024_09_27_172906) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apps", force: :cascade do |t|
    t.string "name"
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_apps_on_name", unique: true
    t.index ["tag"], name: "index_apps_on_tag", unique: true
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

  create_table "consumptions_per_hour", force: :cascade do |t|
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

  create_table "historic_consumptions", force: :cascade do |t|
    t.decimal "value"
    t.integer "period_index"
    t.bigint "meter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meter_id"], name: "index_historic_consumptions_on_meter_id"
  end

  create_table "meters", force: :cascade do |t|
    t.string "service_number"
    t.string "meter_number"
    t.string "deveui"
    t.string "address"
    t.string "client_name"
    t.bigint "zone_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deveui"], name: "index_meters_on_deveui", unique: true
    t.index ["zone_id"], name: "index_meters_on_zone_id"
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

  create_table "user_meters", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "meter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meter_id"], name: "index_user_meters_on_meter_id"
    t.index ["user_id"], name: "index_user_meters_on_user_id"
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

  add_foreign_key "consumptions", "meters"
  add_foreign_key "data_summaries", "meters"
  add_foreign_key "historic_consumptions", "meters"
  add_foreign_key "meters", "zones"
  add_foreign_key "notifications", "notification_types"
  add_foreign_key "user_meters", "meters"
  add_foreign_key "user_meters", "users"
  add_foreign_key "user_notifications", "notifications"
  add_foreign_key "user_notifications", "users"
  add_foreign_key "users", "apps"
end
