require 'spec_helper'

describe Commontator::Comment do
  before do
    setup_spec_variables(true)
    @comment = Commontator::Comment.new
    @comment.thread = @thread
    @comment.creator = @user
    @comment.body = 'Something'
  end
  
  it 'should be votable if acts_as_votable is installed' do
    @comment.is_votable.must_equal @comment.respond_to?(:acts_as_votable)
  end
  
  it 'should know if it has been modified' do
    @comment.save!
    @comment.is_modified?.must_equal false
    sleep 1
    @comment.body = 'Something else'
    @comment.save!
    @comment.is_modified?.must_equal true
  end
  
  it 'should know if it has been deleted' do
    user = User.new
    @comment.is_deleted?.must_equal false
    @comment.deleter.must_be_nil
    @comment.delete(user)
    @comment.is_deleted?.must_equal true
    @comment.deleter.must_equal user
    @comment.undelete
    @comment.is_deleted?.must_equal false
  end
  
  it 'should make proper timestamps' do
    @comment.save!
    @comment.timestamp.must_equal "#{@thread.config.comment_create_verb_past.capitalize} on #{@comment.created_at.strftime(@thread.config.timestamp_format)}"
    sleep 1
    @comment.body = 'Something else'
    @comment.save!
    @comment.timestamp.must_equal "Last modified on #{@comment.updated_at.strftime(@thread.config.timestamp_format)}"
  end
end
