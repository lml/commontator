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
    
    def commontator_gravatar_image_tag(user, border = 1, options = {})
      base = request.ssl? ? "s://secure" : "://www"
      hash = Digest::MD5.hexdigest(commontator_email(user))
      url = "http#{base}.gravatar.com/avatar/#{hash}?#{options.to_query}"

      name = commontator_name(user)
      
      image_tag(url, { :alt => name,
                       :title => name,
                       :border => border })
    end
  
    def commontator_avatar(user)
      user.commontator_config.user_avatar_proc.call(user, self)
    end
  end
end
