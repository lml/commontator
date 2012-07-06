module Commontator
  class Subscription < ActiveRecord::Base

    belongs_to :subscriber, :polymorphic => true
    belongs_to :thread

    validates_presence_of :subscriber, :thread
    validates_uniqueness_of :thread_id, :scope => [:subscriber_id, :subscriber_type]
    
    attr_accessible :subscriber, :thread
    
    def mark_as_read
      self.update_attribute(:is_unread, false)
    end

    def mark_as_unread
      self.update_attribute(:is_unread, true)
    end

  end
end
