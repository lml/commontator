module Commontator
  module CommentsHelper
    def commontator_name(comment)
      commontator = comment.commontator
      config = commontator.commontator_config
      config.commontator_name_method.blank? ? config.anonymous_name : \
      commontator.send(config.commontator_name_method)
    end
    
    def deleter_name(comment)
      deleter = comment.deleter
      config = deleter.commontator_config
      config.commontator_name_method.blank? ? config.anonymous_name : \
      deleter.send(config.commontator_name_method)
    end
    
    def comment_timestamp(comment)
      config = comment.thread.config
      (comment.is_modified? ? 'Last modified on ' : \
        config.comment_create_verb_past.capitalize + \
        ' on ') + comment.updated_at.strftime(config.timestamp_format)
    end
    
    def gravatar_url(comment, options = {})
      commontator = comment.commontator
      config = commontator.commontator_config
      
      options[:secure] ||= request.ssl?
      options[:size] ||= 50
    
      hash = Digest::MD5.hexdigest(commontator.send(config.commontator_email_method))
      base = options[:secure] ? "s://secure" : "://www"
      
      "http#{base}.gravatar.com/avatar/#{hash}?s=#{options[:size]}"
    end
  
    def gravatar_image(comment, options = {})
      commontator = comment.commontator
      config = commontator.commontator_config
      name = commontator.send(config.commontator_name_method)
      image_tag(gravatar_url(comment, options), 
                { :alt => name, 
                  :title => name,
                  :border => 1 })
    end
  end
end
