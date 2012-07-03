module Commontator
  module CommentsHelper
    def commontator_name(commontator)
      config = commontator.commontator_config
      config.name_method.blank? ? 'Anonymous' :\
      commontator.send config.name_method
    end
    
    def comment_timestamp(comment)
      config = comment.thread.config
      (comment.is_modified? ? 'Last ' +\
        config.comment_update_verb_past + ' on ' :\
        config.comment_create_verb_past.capitalize +\
        ' on ') + comment.updated_at.strftime(config.timestamp_format)
    end
    
    def get_comment_and_thread
      @comment = Comment.find(params[:id])
      @thread = @comment.thread
    end
  end
end
