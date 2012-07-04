module Commontator
  module CommontableHelper
    def thread_link(commontable, commontator)
      render(:partial => 'commontables/thread',
             :locals => {:commontable => commontable,
                         :commontator => commontator}).html_safe
    end
  end
end
