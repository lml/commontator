module Commontator
  class Thread < ActiveRecord::Base

    belongs_to :commentable, :polymorphic => true

    has_many :comments, :dependent => :destroy
    has_many :subscriptions, :dependent => :destroy
    has_many :subscribers, :through => :subscriptions

    validates_presence_of :commentable, :allow_nil => true
    validates_uniqueness_of :commentable

    attr_accessible :is_closed

    # Creates a new empty thread and assigns it to the commentable
    # The old thread is kept in the database for archival purposes
    def clear
      new_thread = Thread.new
      new_thread.commentable = commentable
      Thread.transaction do
        new_thread.save!
        commentable.comment_thread = new_thread
        commentable.save!
        subscriptions.each do |s|
          s.comment_thread = new_thread
          s.save!
          s.mark_all_as_read!
        end
        self.commentable = nil
        self.is_closed = true
        self.save!
      end
    end

    def subscription_for(subscriber)
      Subscription.find_by_subscriber_id_and_subscriber_type_and_comment_thread_id(\
        subscriber.id, subscriber.class_name, id)
    end

    def subscribe!(subscriber)
      return false if subscription_for(subscriber)
      subscription = Subscription.create(
        :subscriber => subscriber, :comment_thread => self)
    end

    def unsubscribe!(subscriber)
      subscription = subscription_for(subscriber)
      return false if !subscription
      subscription.destroy
      commentable.respond_to?(:unsubscribe_callback) ? commentable.unsubscribe_callback(subscriber) : true
    end

    def add_unread_except_for(subscriber)
      subscriptions.each { |cts| cts.add_unread! unless cts.subscriber == subscriber }
    end

    def mark_as_read_for(subscriber)
      return if !subscription_for(subscriber)
      subscription_for(subscriber).mark_all_as_read!
    end

    def mark_as_unread_for(subscriber)
      return if !subscription_for(subscriber)
      subscription_for(subscriber).mark_all_as_unread!
    end

    ##########################
    # Access control methods #
    ##########################

    def can_be_read_by?(user)
      commentable.user_can_read_comment_thread?(user)
    end

    def can_be_updated_by?(user)
      commentable.user_can_manage_comment_thread?(user)
    end

    def self.can_be_subscribed_to?
    end

    def self.comments_can_be_edited?
    end

    def self.manager_can_edit_comments?
    end

    def self.creator_can_edit_comments?
    end

    def self.old_comments_can_be_edited?
    end

    def self.comments_can_be_deleted?
    end

    def self.manager_can_deleted_comments?
    end

    def self.creator_can_deleted_comments?
    end

    def self.old_comments_can_be_deleted?
    end

  end
end
