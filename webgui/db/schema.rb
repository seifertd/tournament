# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100312053540) do

  create_table "entries", :force => true do |t|
    t.string   "name",       :limit => 64,                    :null => false
    t.binary   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tie_break"
    t.integer  "user_id",                  :default => 1,     :null => false
    t.integer  "pool_id"
    t.boolean  "completed",                :default => false, :null => false
  end

  add_index "entries", ["pool_id"], :name => "index_entries_on_pool_id"
  add_index "entries", ["user_id"], :name => "index_entries_on_user_id"

  create_table "pools", :force => true do |t|
    t.string   "name",                          :null => false
    t.binary   "data"
    t.boolean  "started",    :default => false, :null => false
    t.datetime "starts_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "active",     :default => false, :null => false
  end

  create_table "regions", :force => true do |t|
    t.integer  "pool_id"
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",       :limit => 32
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",                 :default => 0, :null => false
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "seedings", :force => true do |t|
    t.integer  "pool_id"
    t.integer  "team_id"
    t.string   "region"
    t.integer  "seed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "password_reset_code",       :limit => 40
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
