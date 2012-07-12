require 'commontator/shared_helper'

module Commontator
  module Controllers
    def self.included(base)
      base.helper Commontator::SharedHelper
    end
    
    protected
    
    def commontator_thread_show(commontable, user)
      thread = commontable.thread
      raise SecurityTransgression unless thread.can_be_read_by?(user)
      thread.mark_as_read_for(user)
    end
  end
end

ActionController::Base.send :include, Commontator::Controllers
