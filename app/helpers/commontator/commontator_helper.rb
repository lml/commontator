module Commontator
  module CommontatorHelper
    def commontator_thread_link(commontable)
      render(:partial => 'commontator/commontator/thread_link',
             :locals => {:commontable => commontable}).html_safe
    end
  end
end
