class CreateComments < ActiveRecord::Migration
  def change
    create_table "comment_thread_subscriptions" do |t|
      t.integer  "commenter_id"
      t.string   "commenter_type"
      t.integer  "comment_thread_id"

      t.timestamps
    end

    create_table "comment_threads" do |t|
      t.integer  "commentable_id"
      t.string   "commentable_type"

      t.timestamps
    end

    create_table "comments" do |t|
      t.integer  "comment_thread_id"
      t.integer  "commenter_id"
      t.string   "commenter_type"
      t.text     "body"

      t.timestamps
    end
  end
end
