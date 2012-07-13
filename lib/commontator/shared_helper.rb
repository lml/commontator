module Commontator
  module SharedHelper
    def commontator_thread(commontable)
      user = send Commontator.current_user_method
      
      render(:partial => 'commontator/shared/thread',
             :locals => {:thread => commontable.thread,
                         :user => user}).html_safe
    end
  end
end
