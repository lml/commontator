class AddParentIdToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :commontator_comments, :parent_id, :integer

    add_index :commontator_comments, :parent_id
  end
end
