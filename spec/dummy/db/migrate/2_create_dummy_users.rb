class CreateDummyUsers < ActiveRecord::Migration
  def change
    create_table "dummy_users" do |t|
      t.timestamps
    end
  end
end
