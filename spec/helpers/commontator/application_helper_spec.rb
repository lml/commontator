require 'rails_helper'

module Commontator
  RSpec.describe ApplicationHelper, type: :helper do
    before(:each) do
      setup_model_spec
      @comment = Comment.new
      @comment.thread = @thread
      @comment.creator = @user
      @comment.body = 'Something'
    end

    it 'must print output of javascript proc' do
      expect(javascript_proc).to eq '// Some javascript'
    end

    it 'must make proper timestamps' do
      @comment.save!

      expect(created_timestamp @comment).to eq(
        I18n.t('commontator.comment.status.created_at',
               :created_at => local_time_ago(@comment.created_at,
                                             :format => :commontator))
      )
      expect(updated_timestamp @comment).to eq(
        I18n.t('commontator.comment.status.updated_at',
               :editor_name => @user.name,
               :updated_at => local_time_ago(@comment.updated_at,
                                             :format => :commontator))
      )

      user2 = DummyUser.create
      @comment.body = 'Something else'
      @comment.editor = user2
      @comment.save!

      expect(created_timestamp @comment).to eq(
        I18n.t('commontator.comment.status.created_at',
               :created_at => local_time_ago(@comment.created_at,
                                             :format => :commontator))
      )
      expect(updated_timestamp @comment).to eq(
        I18n.t('commontator.comment.status.updated_at',
               :editor_name => user2.name,
               :updated_at => local_time_ago(@comment.updated_at,
                                             :format => :commontator))
      )
    end
  end
end

