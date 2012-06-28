class CreateComments < ActiveRecord::Migration
  def change
    create_table "comment_thread_subscriptions" do |t|
      t.integer  "comment_thread_id"
      t.integer  "user_id"
      t.integer  "unread_count", :default => 0

      t.timestamps
    end

    create_table "comment_threads" do |t|
      t.string   "commentable_type"
      t.integer  "commentable_id"

      t.timestamps
    end

    create_table "comments" do |t|
      t.integer  "comment_thread_id"
      t.text     "message"
      t.integer  "creator_id"
      t.boolean  "is_log"

      t.timestamps
    end
  end
end
