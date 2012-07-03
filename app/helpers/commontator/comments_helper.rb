module Commontator
  module CommentsHelper
    def modified_string(comment)
      (comment.is_modified? ? "Last modified on " : "Posted on ") +
      comment.updated_at.strftime('%b %d %Y, %I:%M %p')
    end
    
    def get_comment_and_thread
      @comment = Comment.find(params[:id])
      @thread = @comment.thread
    end
  end
end
