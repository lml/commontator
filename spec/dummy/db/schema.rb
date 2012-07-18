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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 2) do

  create_table "commontator_comments", :force => true do |t|
    t.text     "body"
    t.integer  "creator_id"
    t.string   "creator_type"
    t.datetime "deleted_at"
    t.integer  "deleter_id"
    t.string   "deleter_type"
    t.integer  "thread_id"
    t.integer  "cached_votes_total", :default => 0
    t.integer  "cached_votes_up",    :default => 0
    t.integer  "cached_votes_down",  :default => 0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "commontator_comments", ["cached_votes_down"], :name => "index_commontator_comments_on_cached_votes_down"
  add_index "commontator_comments", ["cached_votes_total"], :name => "index_commontator_comments_on_cached_votes_total"
  add_index "commontator_comments", ["cached_votes_up"], :name => "index_commontator_comments_on_cached_votes_up"
  add_index "commontator_comments", ["creator_id", "creator_type", "thread_id"], :name => "index_c_c_on_c_id_and_c_type_and_t_id"
  add_index "commontator_comments", ["thread_id"], :name => "index_commontator_comments_on_thread_id"

  create_table "commontator_subscriptions", :force => true do |t|
    t.integer  "subscriber_id"
    t.string   "subscriber_type"
    t.integer  "thread_id"
    t.integer  "unread",          :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "commontator_subscriptions", ["subscriber_id", "subscriber_type", "thread_id"], :name => "index_c_s_on_s_id_and_s_type_and_t_id", :unique => true
  add_index "commontator_subscriptions", ["thread_id"], :name => "index_commontator_subscriptions_on_thread_id"

  create_table "commontator_threads", :force => true do |t|
    t.integer  "commontable_id"
    t.string   "commontable_type"
    t.datetime "closed_at"
    t.integer  "closer_id"
    t.string   "closer_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "commontator_threads", ["commontable_id", "commontable_type"], :name => "index_commontator_threads_on_commontable_id_and_commontable_type"

  create_table "dummy_models", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dummy_users", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
