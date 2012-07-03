module Commontator
  class Subscription < ActiveRecord::Base

    belongs_to :thread
    belongs_to :subscriber, :polymorphic => true

    attr_accessible :thread, :subscriber

    validates_presence_of :thread, :subscriber
    validates_uniqueness_of :subscriber_id, :scope => :thread_id
    
    scope :subscription_for, lambda { |subscriber, thread|
      where{(subscriber_id == subscriber.id) &\
        (subscriber_type == subscriber.class) &\
        (thread_id == thread.id)}
    }
    
    def email
      subscriber.subscriber_email_method_name.blank? ? '' : subscriber.send subscriber_email_method_name
    end

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
