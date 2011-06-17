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

ActiveRecord::Schema.define(:version => 11) do

  create_table "hosts", :force => true do |t|
    t.string  "name"
    t.integer "rating"
    t.string  "os_name"
    t.string  "os_sp"
    t.integer "pivot_host_id"
    t.string  "arch"
    t.boolean "localhost",     :default => false
    t.boolean "attackable",    :default => false
    t.boolean "ids",           :default => false
    t.string  "webserver"
    t.boolean "discovered",    :default => false, :null => false
    t.string  "os_info"
    t.string  "lang"
  end

  create_table "interfaces", :force => true do |t|
    t.string  "ip"
    t.string  "ip_mask"
    t.string  "ip_ver"
    t.string  "mac"
    t.integer "host_id"
    t.integer "subnet_id"
  end

  create_table "services", :force => true do |t|
    t.string  "name"
    t.string  "port"
    t.string  "proto"
    t.string  "info"
    t.integer "interface_id"
    t.string  "state"
  end

  create_table "sessions", :force => true do |t|
    t.string   "name"
    t.integer  "host_id"
    t.integer  "service_id"
    t.string   "payload"
    t.string   "exploit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.string   "error"
    t.string   "progress"
    t.boolean  "completed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_dialogs", :force => true do |t|
    t.string   "title"
    t.string   "message"
    t.integer  "dialog_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
