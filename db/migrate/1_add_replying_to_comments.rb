class AddReplyingToComments < ActiveRecord::Migration[5.2]
  def change
    add_reference :commontator_comments, :parent, foreign_key: {
      to_table: :commontator_comments, on_update: :restrict, on_delete: :cascade
    }
    add_column :commontator_comments, :level, :integer, default: 0, null: false
    add_column :commontator_comments, :ancestor_ids, :text
    add_column :commontator_comments, :descendant_ids, :text

    add_index :commontator_comments, [ :id, :level ], unique: true
  end
end
