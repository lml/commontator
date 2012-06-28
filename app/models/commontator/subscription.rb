module Commontator
  class Subscription < ActiveRecord::Base

    belongs_to :comment_thread
    belongs_to :subscriber, :polymorphic => true
    has_one :commentable, :through => :comment_thread

    attr_accessible :subscriber, :comment_thread

    validates_presence_of :comment_thread, :subscriber
    validates_uniqueness_of :subscriber_id, :scope => :comment_thread_id

    scope :subscriptions_for, lambda { |subscriber|
      where{subscriber_id == subscriber.id}
    }

    def mark_all_as_read!
      self.transaction do
        user.update_attribute(:unread_count, user.unread_count - self.unread_count)
        self.update_attribute(:unread_count, 0)
      end
    end

    def mark_all_as_unread!
      self.transaction do
        user.update_attribute(:unread_count, user.unread_count - self.unread_count + comment_thread.comments.count)
        self.update_attribute(:unread_count, comment_thread.comments.count)
      end
    end

    def add_unread!
      self.transaction do
        user.update_attribute(:unread_count, unread_count + 1)
        update_attribute(:unread_count, unread_count + 1)
      end
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
