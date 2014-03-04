module Commontator
  module SharedHelper
    def commontator_thread(commontable)
      user = Commontator.current_user_proc.call(self)
      
      render(:partial => 'commontator/shared/thread',
             :locals => {:thread => commontable.thread,
                         :user => user}).html_safe
    end
    
    def commontator_name(user)
      user.commontator_config.user_name_proc.call(user)
    end
    
    def commontator_email(user)
      user.commontator_config.user_email_proc.call(user)
    end
    
    def commontator_gravatar_url(user, options = {})
      options[:secure] ||= request.ssl?
      options[:size] ||= 50
    
      hash = Digest::MD5.hexdigest(commontator_email(user))
      base = options[:secure] ? "s://secure" : "://www"
      
      "http#{base}.gravatar.com/avatar/#{hash}?s=#{options[:size]}"
    end
  
    def commontator_avatar(user, options = {})
      name = commontator_name(user)
      image_tag(commontator_gravatar_url(user, options), 
                { :alt => name, 
                  :title => name,
                  :border => 1 })
    end
  end
end
