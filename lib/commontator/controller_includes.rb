require 'commontator/shared_helper'

module Commontator
  module ControllerIncludes
    def self.included(base)
      base.helper Commontator::SharedHelper
    end
    
    protected
    
    def commontator_thread_show(commontable, user)
      thread = commontable.thread
      raise SecurityTransgression unless thread.can_be_read_by?(user)
      thread.mark_as_read_for(user)
      @commontator_thread_show = true
    end
  end
end

ActionController::Base.send :include, Commontator::ControllerIncludes
