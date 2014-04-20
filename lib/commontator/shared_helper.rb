module Commontator
  module SharedHelper
    def commontator_thread(commontable)
      user = Commontator.current_user_proc.call(self)
      
      render(:partial => 'commontator/shared/thread',
             :locals => {:thread => commontable.thread,
                         :user => user}).html_safe
    end

    def commontator_gravatar_image_tag(user, border = 1, options = {})
      base = request.ssl? ? "s://secure" : "://www"
      hash = Digest::MD5.hexdigest(user.commontator_email)
      url = "http#{base}.gravatar.com/avatar/#{hash}?#{options.to_query}"
      
      name = user.commontator_name
      
      image_tag(url, { :alt => name,
                :title => name,
                :border => border })
    end
  end
end

