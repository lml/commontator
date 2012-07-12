module Commontator
  module CommentsHelper
    def creator_name(comment)
      user = comment.creator
      return Commontator.user_missing_name if user.nil?
      config = user.commontator_config
      config.user_name_method.blank? ? config.user_missing_name : \
        user.send(config.user_name_method)
    end
    
    def deleter_name(comment)
      user = comment.deleter
      return Commontator.user_missing_name if user.nil?
      config = user.commontator_config
      config.user_name_method.blank? ? config.user_missing_name : \
        user.send(config.user_name_method)
    end
    
    def comment_timestamp(comment)
      config = comment.thread.config
      (comment.is_modified? ? 'Last modified on ' : \
        config.comment_create_verb_past.capitalize + \
        ' on ') + comment.updated_at.strftime(config.timestamp_format)
    end
    
    def gravatar_url(comment, options = {})
      user = comment.creator
      return '' if user.nil?
      config = user.commontator_config
      
      options[:secure] ||= request.ssl?
      options[:size] ||= 50
    
      hash = Digest::MD5.hexdigest(user.send(config.user_email_method))
      base = options[:secure] ? "s://secure" : "://www"
      
      "http#{base}.gravatar.com/avatar/#{hash}?s=#{options[:size]}"
    end
  
    def gravatar_image(comment, options = {})
      user = comment.creator
      return '' if user.nil?
      config = user.commontator_config
      name = user.send(config.user_name_method)
      image_tag(gravatar_url(comment, options), 
                { :alt => name, 
                  :title => name,
                  :border => 1 })
    end
  end
end
