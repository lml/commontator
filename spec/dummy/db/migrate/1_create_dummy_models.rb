class CreateDummyModels < ActiveRecord::Migration
  def change
    create_table "dummy_models" do |t|
      t.timestamps
    end
  end
end
