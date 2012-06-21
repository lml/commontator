module CommentThread::ActsAsCommentable
  module ClassMethods
    def acts_as_commentable(options = {})
      # your code will go here
    end
  end
end

ActiveRecord::Base.send :include, CommentThread::ActsAsCommentable
