module CommentThread::ActsAsCommenter
  module ClassMethods
    def acts_as_commenter(options = {})
      # your code will go here
    end
  end
end

ActiveRecord::Base.send :include, CommentThread::ActsAsCommenter
