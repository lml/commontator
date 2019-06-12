class CreateDummyDependentModels < ActiveRecord::Migration[5.2]
  def change
    create_table :dummy_dependent_models do |t|
      t.timestamps null: false
    end
  end
end
