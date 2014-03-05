module Commontator
  module CommentsHelper
    def created_timestamp(comment)
      t 'commontator.comment.status.created_at',
      :created_at => l(comment.created_at, :format => :commontator)
    end

    def updated_timestamp(comment)
      editor = comment.editor
      return '' if editor.nil?

      t 'commontator.comment.status.updated_at',
        :editor_name => editor.commontator_config.user_name_proc.call(editor),
        :updated_at => l(comment.updated_at, :format => :commontator)
    end
  end
end
