# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150914204557) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arrivals", force: :cascade do |t|
    t.integer "trip_id"
    t.integer "station_id"
  end

  add_index "arrivals", ["station_id"], name: "index_arrivals_on_station_id", using: :btree
  add_index "arrivals", ["trip_id"], name: "index_arrivals_on_trip_id", using: :btree

  create_table "departures", force: :cascade do |t|
    t.integer "trip_id"
    t.integer "station_id"
  end

  add_index "departures", ["station_id"], name: "index_departures_on_station_id", using: :btree
  add_index "departures", ["trip_id"], name: "index_departures_on_trip_id", using: :btree

  create_table "stations", force: :cascade do |t|
    t.integer "cabi_id"
    t.string  "station_name"
    t.decimal "latitude"
    t.decimal "longitude"
  end

  create_table "trips", force: :cascade do |t|
    t.integer  "duration"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  add_foreign_key "arrivals", "stations"
  add_foreign_key "arrivals", "trips"
  add_foreign_key "departures", "stations"
  add_foreign_key "departures", "trips"
end
