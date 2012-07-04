module Commontator
  module CommentsHelper
    def commontator_name(comment)
      commontator = comment.commontator
      config = commontator.commontator_config
      config.commontator_name_method.blank? ? config.anonymous_name :\
      commontator.send config.commontator_name_method
    end
    
    def deleter_name(comment)
      deleter = comment.deleter
      config = deleter.commontator_config
      config.commontator_name_method.blank? ? config.anonymous_name :\
      deleter.send config.commontator_name_method
    end
    
    def comment_timestamp(comment)
      config = comment.thread.config
      (comment.is_modified? ? 'Last modified on ' :\
        config.comment_create_verb_past.capitalize +\
        ' on ') + comment.updated_at.strftime(config.timestamp_format)
    end
    
    def get_comment_and_thread
      @comment = Comment.find(params[:id])
      @thread = @comment.thread
    end
  end
end
