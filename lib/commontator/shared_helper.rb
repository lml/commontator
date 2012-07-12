module Commontator
  module SharedHelper
    def commontator_thread_link(commontable, user, show = nil)
      render(:partial => 'commontator/shared/thread_link',
             :locals => {:thread => commontable.thread,
                         :user => user,
                         :show => show}).html_safe
    end
  end
end
