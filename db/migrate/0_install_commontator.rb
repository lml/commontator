class InstallCommontator < ActiveRecord::Migration
  def change
    create_table "subscriptions" do |t|
      t.integer  "subscriber_id"
      t.string   "subscriber_type"
      t.integer  "thread_id"
      t.integer  "unread"

      t.timestamps
    end

    create_table "threads" do |t|
      t.integer  "commontable_id"
      t.string   "commontable_type"
      t.boolean  "is_closed"

      t.timestamps
    end

    create_table "comments" do |t|
      t.integer  "thread_id"
      t.integer  "commontator_id"
      t.string   "commontator_type"
      t.text     "body"

      t.timestamps
    end
  end
end
