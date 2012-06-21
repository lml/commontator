module CommentThread::ThreadsHelper

  def find_commentable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end

  def get_thread
    commentable = find_commentable
    @thread = commentable.thread
    @commentable = commentable.becomes(@comment_thread.commentable_type.constantize)
  end

end

