module Commontator
  class Subscription < ActiveRecord::Base

    belongs_to :thread
    belongs_to :subscriber, :polymorphic => true

    attr_accessible :thread, :subscriber

    validates_presence_of :thread, :subscriber
    validates_uniqueness_of :subscriber_id, :scope => :thread_id

    def mark_all_as_read
      self.update_attribute(:unread, 0)
    end

    def mark_all_as_unread
      self.update_attribute(:unread, thread.comments.count)
    end

    def add_unread
      self.update_attribute(:unread, unread + 1)
    end

    ##########################
    # Access control methods #
    ##########################

    def can_be_created_by?(user)
      Thread.can_be_subscribed_to? && user == subscriber
    end

    def can_be_destroyed_by?(user)
      Thread.can_be_subscribed_to? && user == subscriber
    end

  end
end
