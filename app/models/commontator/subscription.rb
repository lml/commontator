module Commontator
  class Subscription < ActiveRecord::Base

    belongs_to :subscriber, :polymorphic => true
    belongs_to :thread

    attr_accessible :subscriber, :thread

    validates_presence_of :subscriber, :thread
    validates_uniqueness_of :thread_id, :scope => [:subscriber_id, :subscriber_type]
    
    scope :subscription_for, lambda { |subscriber, thread|
      where(:subscriber_id => subscriber.id,
            :subscriber_type => subscriber.class.name,
            :thread_id => thread.id)
    }

    def mark_all_as_read
      self.update_attribute(:unread, 0)
    end

    def mark_all_as_unread
      self.update_attribute(:unread, thread.comments.count)
    end

    def add_unread
      self.update_attribute(:unread, unread + 1)
    end

  end
end
