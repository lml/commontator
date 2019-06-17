class AddNestingToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :commontator_comments, :parent_id, :integer
    add_column :commontator_comments, :ancestor_ids, :text
    add_column :commontator_comments, :descendant_ids, :text

    add_index :commontator_comments, :parent_id
  end
end
