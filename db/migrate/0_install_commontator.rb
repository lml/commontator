class InstallCommontator < ActiveRecord::Migration
  def change
    create_table "comments" do |t|
      t.text     "body"
      t.integer  "commontator_id"
      t.string   "commontator_type"
      t.datetime "deleted_at"
      t.integer  "deleter_id"
      t.string   "deleter_type"
      t.integer  "thread_id"

      t.timestamps
    end
    
    create_table "subscriptions" do |t|
      t.integer  "subscriber_id"
      t.string   "subscriber_type"
      t.integer  "thread_id"
      t.boolean  "is_unread"

      t.timestamps
    end

    create_table "threads" do |t|
      t.integer  "commontable_id"
      t.string   "commontable_type"
      t.datetime "closed_at"
      t.integer  "closer_id"
      t.string   "closer_type"

      t.timestamps
    end
    
    add_index :comments, [:commontator_id, :commontator_type, :thread_id]
    add_index :comments, :thread_id
    add_index :subscriptions, [:subscriber_id, :subscriber_type, :thread_id], :unique => true
    add_index :subscriptions, :thread_id
    add_index :threads, [:commontable_id, :commontable_type]
  end
end
