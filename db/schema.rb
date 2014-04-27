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

ActiveRecord::Schema.define(version: 2) do

  create_table "transactions", force: true do |t|
    t.datetime "created"
    t.float    "amount"
    t.integer  "user_id"
    t.string   "thash"
  end

  add_index "transactions", ["thash"], name: "index_transactions_on_thash", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "phash"
    t.string   "salt"
    t.float    "balance"
    t.string   "token"
    t.datetime "token_expires"
  end

  add_index "users", ["token"], name: "index_users_on_token", using: :btree

end
