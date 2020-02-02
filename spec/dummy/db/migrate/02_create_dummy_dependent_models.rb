class CreateDummyDependentModels < ActiveRecord::Migration[5.2]
  def change
    create_table :dummy_dependent_models do |t|
      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do
        DummyDependentModel.create
        DummyDependentModel.delete_all
      end
    end
  end
end
