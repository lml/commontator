module Commontator
  module CommontableHelper
    def thread_link(commontable, commontator)
      thread = commontable.thread
      render(:partial => 'threads/link',
             :locals => {:thread => thread,
                         :commontator => commontator}).html_safe
    end
  end
end
