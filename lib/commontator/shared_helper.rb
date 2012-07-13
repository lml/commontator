module Commontator
  module SharedHelper
    def commontator_thread(commontable, user)
      render(:partial => 'commontator/shared/thread',
             :locals => {:thread => commontable.thread,
                         :user => user}).html_safe
    end
  end
end
