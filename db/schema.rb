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

ActiveRecord::Schema[8.1].define(version: 2026_03_19_010049) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "booking_status", ["pending", "confirmed", "cancelled", "completed"]
  create_enum "payment_method", ["card", "cash"]
  create_enum "payment_status", ["pending", "paid", "failed", "refunded"]
  create_enum "user_role", ["admin", "user"]

  create_table "bookings", primary_key: "booking_id", force: :cascade do |t|
    t.date "check_in_date", null: false
    t.date "check_out_date", null: false
    t.datetime "created_at", null: false
    t.integer "guests_count", null: false
    t.integer "room_id", null: false
    t.string "status", default: "pending"
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["created_at"], name: "index_bookings_on_created_at"
    t.index ["room_id", "check_in_date", "check_out_date"], name: "index_bookings_on_room_id_and_check_in_date_and_check_out_date"
    t.index ["room_id", "check_in_date"], name: "idx_prevent_double_booking", unique: true, where: "((status)::text = ANY ((ARRAY['pending'::character varying, 'confirmed'::character varying])::text[]))"
    t.index ["room_id"], name: "index_bookings_on_room_id"
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.check_constraint "check_out_date > check_in_date", name: "check_dates"
    t.check_constraint "guests_count > 0", name: "guests_count_check"
    t.check_constraint "total_price > 0::numeric", name: "total_price_check"
  end

  create_table "hotels", primary_key: "hotel_id", force: :cascade do |t|
    t.string "address", null: false
    t.string "city", null: false
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "phone"
    t.integer "stars"
    t.datetime "updated_at", null: false
    t.boolean "visa_required", default: false
    t.index ["city"], name: "index_hotels_on_city"
    t.index ["country"], name: "index_hotels_on_country"
    t.index ["stars"], name: "index_hotels_on_stars"
    t.check_constraint "stars >= 1 AND stars <= 5", name: "stars_check"
  end

  create_table "payments", primary_key: "payment_id", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "booking_id", null: false
    t.datetime "created_at", null: false
    t.datetime "paid_at", precision: nil
    t.string "payment_method", default: "card"
    t.string "payment_status", default: "pending"
    t.string "transaction_id"
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
    t.index ["paid_at"], name: "index_payments_on_paid_at"
    t.index ["payment_method"], name: "index_payments_on_payment_method"
    t.index ["payment_status"], name: "index_payments_on_payment_status"
    t.index ["transaction_id"], name: "index_payments_on_transaction_id", unique: true
    t.check_constraint "amount > 0::numeric", name: "amount_check"
  end

  create_table "rooms", primary_key: "room_id", force: :cascade do |t|
    t.string "amenities", default: [], array: true
    t.integer "capacity", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "hotel_id", null: false
    t.boolean "is_available", default: true
    t.decimal "price_per_night", precision: 10, scale: 2, null: false
    t.string "room_number", null: false
    t.string "room_type", null: false
    t.datetime "updated_at", null: false
    t.index ["capacity"], name: "index_rooms_on_capacity"
    t.index ["hotel_id", "room_number"], name: "index_rooms_on_hotel_id_and_room_number", unique: true
    t.index ["hotel_id"], name: "index_rooms_on_hotel_id"
    t.index ["price_per_night"], name: "index_rooms_on_price_per_night"
    t.index ["room_type"], name: "index_rooms_on_room_type"
    t.check_constraint "capacity > 0", name: "capacity_check"
    t.check_constraint "price_per_night > 0::numeric", name: "price_check"
  end

  create_table "users", primary_key: "user_id", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.boolean "has_visa", default: false
    t.string "password_hash", null: false
    t.string "phone"
    t.string "role", default: "user"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "bookings", "rooms", primary_key: "room_id"
  add_foreign_key "bookings", "users", primary_key: "user_id"
  add_foreign_key "payments", "bookings", primary_key: "booking_id"
  add_foreign_key "rooms", "hotels", primary_key: "hotel_id"
end
