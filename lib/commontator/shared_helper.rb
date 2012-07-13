module Commontator
  module SharedHelper
    def commontator_thread(commontable)
      user = send Commontator.current_user_method
      
      render(:partial => 'commontator/shared/thread',
             :locals => {:thread => commontable.thread,
                         :user => user}).html_safe
    end
    
    def commontator_name(user)
      return Commontator.user_missing_name if user.nil?
      config = user.commontator_config
      config.user_name_method.blank? ? config.user_missing_name : \
        user.send(config.user_name_method)
    end
    
    def commontator_email(user)
      return '' if user.nil?
      config = user.commontator_config
      config.email_method.blank? ? '' : user.send(config.email_method)
    end
    
    def commontator_gravatar_url(user, options = {})
      options[:secure] ||= request.ssl?
      options[:size] ||= 50
    
      hash = Digest::MD5.hexdigest(commontator_email(user))
      base = options[:secure] ? "s://secure" : "://www"
      
      "http#{base}.gravatar.com/avatar/#{hash}?s=#{options[:size]}"
    end
  
    def commontator_gravatar_image(user, options = {})
      name = commontator_name(user)
      image_tag(commontator_gravatar_url(user, options), 
                { :alt => name, 
                  :title => name,
                  :border => 1 })
    end
  end
end
