class Install < ActiveRecord::Migration
  def change
    create_table "commontator_comments" do |t|
      t.text     "body"
      t.integer  "creator_id"
      t.string   "creator_type"
      t.datetime "deleted_at"
      t.integer  "deleter_id"
      t.string   "deleter_type"
      t.integer  "thread_id"
      
      t.integer  "cached_votes_total", :default => 0
      t.integer  "cached_votes_up", :default => 0
      t.integer  "cached_votes_down", :default => 0

      t.timestamps
    end
    
    create_table "commontator_subscriptions" do |t|
      t.integer  "subscriber_id"
      t.string   "subscriber_type"
      t.integer  "thread_id"
      t.integer  "unread", :default => 0

      t.timestamps
    end

    create_table "commontator_threads" do |t|
      t.integer  "commontable_id"
      t.string   "commontable_type"
      t.datetime "closed_at"
      t.integer  "closer_id"
      t.string   "closer_type"

      t.timestamps
    end
    
    add_index :commontator_comments, [:creator_id, :creator_type, :thread_id], :name => "index_c_c_on_c_id_and_c_type_and_t_id"
    add_index :commontator_comments, :thread_id
    add_index :commontator_subscriptions, [:subscriber_id, :subscriber_type, :thread_id], :unique => true, :name => "index_c_s_on_s_id_and_s_type_and_t_id"
    add_index :commontator_subscriptions, :thread_id
    add_index :commontator_threads, [:commontable_id, :commontable_type]
    
    add_index :commontator_comments, :cached_votes_total
    add_index :commontator_comments, :cached_votes_up
    add_index :commontator_comments, :cached_votes_down
  end
end
