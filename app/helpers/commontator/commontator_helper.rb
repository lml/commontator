module Commontator
  module CommontatorHelper
    def commontator_thread_link(commontable)
      render(:partial => 'commontator/shared/thread_link',
             :locals => {:thread => commontable.thread}).html_safe
    end
  end
end
