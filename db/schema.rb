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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110310000001) do

  create_table "gps_locations", :force => true do |t|
    t.string   "gpsd_class"
    t.string   "tag"
    t.string   "device"
    t.float    "time"
    t.float    "lat"
    t.float    "lon"
    t.float    "alt"
    t.float    "epx"
    t.float    "epy"
    t.float    "epv"
    t.float    "ept"
    t.float    "track"
    t.float    "speed"
    t.float    "climb"
    t.integer  "mode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.geometry "geom",       :limit => nil
  end

  create_table "manual_locations", :force => true do |t|
    t.integer  "map_id"
    t.integer  "x"
    t.integer  "y"
    t.float    "height"
    t.float    "u_x"
    t.float    "u_y"
    t.integer  "time",       :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.geometry "geom",       :limit => nil
  end

  create_table "map_relations", :force => true do |t|
    t.integer  "basis_map_id"
    t.integer  "relative_map_id"
    t.float    "alt_diff"
    t.float    "brng_diff"
    t.integer  "ref_x"
    t.integer  "ref_y"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maps", :force => true do |t|
    t.string   "name"
    t.float    "o_lat"
    t.float    "o_lon"
    t.float    "o_alt"
    t.integer  "o_x"
    t.integer  "o_y"
    t.float    "dist_pix_ratio"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.geometry "geom",               :limit => nil
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.float    "brng"
  end

  create_table "movement_logs", :force => true do |t|
    t.integer  "gps_location_id"
    t.integer  "manual_location_id"
    t.integer  "user_id"
    t.string   "remote_addr"
    t.string   "user_agent"
    t.string   "user_device"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "wifi_access_points", :force => true do |t|
    t.string   "ssid"
    t.string   "mac"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manual_location_id"
  end

  create_table "wifi_logs", :force => true do |t|
    t.integer  "wifi_access_point_id"
    t.integer  "movement_log_id"
    t.integer  "signal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
