class CreateDummyUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :dummy_users do |t|
      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do
        DummyUser.create
        DummyUser.delete_all
      end
    end
  end
end
