module Commontator
  module Controllers
    def self.included(base)
      base.helper_method :commontator_thread_link
    end
    
    protected
    
    def commontator_thread_show(commontable, user)
      thread = commontable.thread
      raise SecurityTransgression unless thread.can_be_read_by?(user)
      thread.mark_as_read_for(user)
    end
    
    def commontator_thread_link(commontable, user, show = nil)
      render(:partial => 'commontator/shared/thread_link',
             :locals => {:thread => commontable.thread,
                         :user => user,
                         :show => show}).html_safe
    end
  end
end

ActionController::Base.send :include, Commontator::Controllers
