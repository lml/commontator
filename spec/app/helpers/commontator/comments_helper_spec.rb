require 'test_helper'

module Commontator
  describe CommentsHelper do
    before do
      setup_helper_spec
    end
    
    it 'must make proper timestamps' do
      editor_name = @user.commontator_config.user_name_proc.call(@user)
      created_timestamp(@comment).must_equal t('commontator.comment.status.created_at',
                                               :created_at => l(@comment.created_at,
                                                                :format => :commontator))
      updated_timestamp(@comment).must_equal ''

      @comment.body = 'Something else'
      @comment.editor = @user
      @comment.save!

      created_timestamp(@comment).must_equal t('commontator.comment.status.created_at',
                                               :created_at => l(@comment.created_at,
                                                                :format => :commontator))
      updated_timestamp(@comment).must_equal t('commontator.comment.status.updated_at',
                                               :editor_name => editor_name,
                                               :updated_at => l(@comment.updated_at,
                                                                :format => :commontator))
    end
  end
end
